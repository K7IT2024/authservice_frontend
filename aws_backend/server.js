const express = require('express');
const AWS = require('aws-sdk');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'otp_store.json');

const sns = new AWS.SNS({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'ap-south-1',
});

function loadStore() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8')) || {};
    }
  } catch (err) {
    console.error('Failed to read OTP store:', err);
  }
  return {};
}

function saveStore(store) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(store, null, 2), 'utf8');
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function validatePhoneNumber(phoneNumber) {
  return /^\+\d{10,15}$/.test(phoneNumber);
}

app.post('/send-otp', async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    if (!phoneNumber) {
      return res.status(400).json({ error: 'Phone number is required.' });
    }

    if (!validatePhoneNumber(phoneNumber)) {
      return res.status(400).json({ error: 'Phone number must be in E.164 format, e.g. +919876543210.' });
    }

    const otp = generateOtp();
    const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes
    const store = loadStore();
    store[phoneNumber] = {
      otp,
      expiresAt,
      attempts: 0,
      createdAt: Date.now(),
    };
    saveStore(store);

    const params = {
      Message: `Your OTP is: ${otp}. Valid for 10 minutes.`,
      PhoneNumber: phoneNumber,
    };

    await sns.publish(params).promise();

    return res.json({ success: true, message: 'OTP sent successfully.', expiresIn: 600 });
  } catch (error) {
    console.error('Error in send-otp:', error);
    return res.status(500).json({ error: error.message || 'Failed to send OTP' });
  }
});

app.post('/verify-otp', async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;
    if (!phoneNumber || !otp) {
      return res.status(400).json({ error: 'Phone number and OTP are required.' });
    }

    const store = loadStore();
    const entry = store[phoneNumber];
    if (!entry) {
      return res.status(400).json({ error: 'No OTP request found for this phone number.' });
    }

    if (Date.now() > entry.expiresAt) {
      delete store[phoneNumber];
      saveStore(store);
      return res.status(400).json({ error: 'OTP expired. Please request a new one.' });
    }

    if (entry.attempts >= 5) {
      delete store[phoneNumber];
      saveStore(store);
      return res.status(400).json({ error: 'Too many failed attempts. Please request a new OTP.' });
    }

    if (entry.otp !== otp) {
      entry.attempts += 1;
      saveStore(store);
      return res.status(400).json({ error: 'Invalid OTP.' });
    }

    delete store[phoneNumber];
    saveStore(store);

    return res.json({ success: true, message: 'OTP verified successfully.', userId: phoneNumber });
  } catch (error) {
    console.error('Error in verify-otp:', error);
    return res.status(500).json({ error: error.message || 'Failed to verify OTP' });
  }
});

app.post('/resend-otp', async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    if (!phoneNumber) {
      return res.status(400).json({ error: 'Phone number is required.' });
    }

    if (!validatePhoneNumber(phoneNumber)) {
      return res.status(400).json({ error: 'Phone number must be in E.164 format, e.g. +919876543210.' });
    }

    const store = loadStore();
    if (!store[phoneNumber]) {
      return res.status(400).json({ error: 'No existing OTP request found. Please send OTP first.' });
    }

    const otp = generateOtp();
    const expiresAt = Date.now() + 10 * 60 * 1000;

    store[phoneNumber] = {
      otp,
      expiresAt,
      attempts: 0,
      createdAt: Date.now(),
    };
    saveStore(store);

    const params = {
      Message: `Your OTP is: ${otp}. Valid for 10 minutes.`,
      PhoneNumber: phoneNumber,
    };

    await sns.publish(params).promise();

    return res.json({ success: true, message: 'OTP resent successfully.', expiresIn: 600 });
  } catch (error) {
    console.error('Error in resend-otp:', error);
    return res.status(500).json({ error: error.message || 'Failed to resend OTP' });
  }
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`AWS SNS backend running on http://localhost:${PORT}`);
});
