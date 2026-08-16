const functions = require('firebase-functions');
const admin = require('firebase-admin');
const AWS = require('aws-sdk');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

const awsConfig = functions.config().aws || {};

function createSnsClient() {
  if (!awsConfig.access_key_id || !awsConfig.secret_access_key) {
    throw new Error('AWS credentials are not configured. Use firebase functions:config:set aws.access_key_id and aws.secret_access_key.');
  }

  return new AWS.SNS({
    accessKeyId: awsConfig.access_key_id,
    secretAccessKey: awsConfig.secret_access_key,
    region: awsConfig.region || 'ap-south-1'
  });
}

const snsClient = createSnsClient();

// Generate random 6-digit OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send OTP via AWS SNS
exports.sendOTP = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      const { phoneNumber } = req.body;

      if (!phoneNumber) {
        return res.status(400).json({ error: 'Phone number is required' });
      }

      // Validate phone number format (E.164)
      if (!/^\+\d{1,15}$/.test(phoneNumber)) {
        return res.status(400).json({ error: 'Invalid phone number format. Use E.164 format (+1234567890)' });
      }

      // Generate OTP
      const otp = generateOTP();
      const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes

      // Store OTP in Firestore
      const docId = phoneNumber.replace(/\+/g, '').replace(/\D/g, '');
      await db.collection('otp_store').doc(docId).set({
        phoneNumber,
        otp,
        expiresAt,
        attempts: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // Send SMS via AWS SNS
      const params = {
        Message: `Your OTP is: ${otp}. Valid for 10 minutes.`,
        PhoneNumber: phoneNumber
      };

      await snsClient.publish(params).promise();

      console.log(`OTP sent to ${phoneNumber}`);
      res.json({
        success: true,
        message: 'OTP sent successfully',
        expiresIn: 600 // 10 minutes in seconds
      });
    } catch (error) {
      console.error('Error sending OTP:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

// Verify OTP and create auth token
exports.verifyOTP = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      const { phoneNumber, otp } = req.body;

      if (!phoneNumber || !otp) {
        return res.status(400).json({ error: 'Phone number and OTP are required' });
      }

      const docId = phoneNumber.replace(/\+/g, '').replace(/\D/g, '');
      const docRef = db.collection('otp_store').doc(docId);
      const docSnap = await docRef.get();

      if (!docSnap.exists) {
        return res.status(400).json({ error: 'OTP not found. Please request a new OTP.' });
      }

      const data = docSnap.data();

      // Check if OTP is expired
      if (Date.now() > data.expiresAt) {
        await docRef.delete();
        return res.status(400).json({ error: 'OTP expired. Please request a new one.' });
      }

      // Check attempts (max 5)
      if (data.attempts >= 5) {
        await docRef.delete();
        return res.status(400).json({ error: 'Too many failed attempts. Please request a new OTP.' });
      }

      // Verify OTP
      if (data.otp !== otp) {
        // Increment attempts
        await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
        return res.status(400).json({ error: 'Invalid OTP.' });
      }

      // OTP verified - delete and create/update user
      await docRef.delete();

      // Get or create user
      let user = await admin.auth().getUserByPhoneNumber(phoneNumber).catch(() => null);

      if (!user) {
        // Create new user
        user = await admin.auth().createUser({ phoneNumber });
      }

      // Create custom token for client
      const customToken = await admin.auth().createCustomToken(user.uid);

      // Store user phone in Firestore
      await db.collection('users').doc(user.uid).set({
        phoneNumber,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      res.json({
        success: true,
        token: customToken,
        userId: user.uid,
        message: 'OTP verified successfully'
      });
    } catch (error) {
      console.error('Error verifying OTP:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

// Resend OTP (same phone number)
exports.resendOTP = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      const { phoneNumber } = req.body;

      if (!phoneNumber) {
        return res.status(400).json({ error: 'Phone number is required' });
      }

      const docId = phoneNumber.replace(/\+/g, '').replace(/\D/g, '');
      const docRef = db.collection('otp_store').doc(docId);
      const docSnap = await docRef.get();

      if (!docSnap.exists) {
        return res.status(400).json({ error: 'No pending OTP request. Please start a new request.' });
      }

      // Delete old OTP and send new one
      await docRef.delete();

      // Generate and send new OTP
      const otp = generateOTP();
      const expiresAt = Date.now() + 10 * 60 * 1000;

      await db.collection('otp_store').doc(docId).set({
        phoneNumber,
        otp,
        expiresAt,
        attempts: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      const params = {
        Message: `Your OTP is: ${otp}. Valid for 10 minutes.`,
        PhoneNumber: phoneNumber
      };

      await snsClient.publish(params).promise();

      res.json({
        success: true,
        message: 'New OTP sent successfully',
        expiresIn: 600
      });
    } catch (error) {
      console.error('Error resending OTP:', error);
      res.status(500).json({ error: error.message });
    }
  });
});
