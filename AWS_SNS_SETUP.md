# AWS SNS OTP Implementation Guide

## Overview
This implementation replaces Firebase Phone Auth with AWS SNS for sending SMS OTPs. It uses Firebase Cloud Functions as a backend proxy to AWS SNS.

**Cost:** 1,000 free SMS/month (AWS free tier), then $0.00645 per SMS.

---

## Prerequisites

1. **Firebase project** (already have: k7-iam)
2. **AWS account** (create at https://aws.amazon.com/free)
3. **Node.js 20+** installed on your PC
4. **Firebase CLI** installed (`npm install -g firebase-tools`)

---

## Step 1: Set Up AWS SNS

### 1.1 Create AWS Account
- Go to https://aws.amazon.com/free
- Sign up for free tier

### 1.2 Create IAM User for SNS
1. AWS Console → IAM → Users
2. Create new user: `firebase-sns-user`
3. Attach policy: `AmazonSNSFullAccess`
4. Generate Access Key ID and Secret Access Key
5. **Save these securely** — you'll need them in Step 3

### 1.3 Verify Phone Number in SNS (Sandbox mode)
1. AWS Console → SNS → Text Messaging
2. Under "Origination identities" → Add phone number
3. Enter your phone number in E.164 format (e.g., `+919876543210`)
4. Verify via text message from AWS

---

## Step 2: Set Up Firebase Cloud Functions

### 2.1 Initialize Cloud Functions
```bash
cd d:\LoginService\frontend\auth_flutter\functions
npm install
```

### 2.2 Deploy Functions
```bash
firebase deploy --only functions
```

If you haven't logged in, run:
```bash
firebase login
```

Then select your Firebase project (`k7-iam`) when prompted.

---

## Step 3: Set Environment Variables

### 3.1 Set AWS Credentials in Firebase
Replace `YOUR_XXX` with your actual AWS values from Step 1.2:

```bash
firebase functions:config:set aws.access_key_id="YOUR_ACCESS_KEY_ID"
firebase functions:config:set aws.secret_access_key="YOUR_SECRET_ACCESS_KEY"
firebase functions:config:set aws.region="us-east-1"
```

### 3.2 Deploy Again
```bash
firebase deploy --only functions
```

### 3.3 View Your Function URLs
After deployment, you'll see URLs like:
```
✔  functions[sendOTP]: url: https://us-central1-k7-iam.cloudfunctions.net/sendOTP
✔  functions[verifyOTP]: url: https://us-central1-k7-iam.cloudfunctions.net/verifyOTP
✔  functions[resendOTP]: url: https://us-central1-k7-iam.cloudfunctions.net/resendOTP
```

Copy these URLs — you'll use them in your Flutter app.

---

## Step 4: Update Flutter App

### 4.1 Update pubspec.yaml
Ensure you have:
```yaml
dependencies:
  firebase_core: ^latest
  firebase_functions: ^latest
```

Then run:
```bash
flutter pub get
```

### 4.2 Update Your Login Screen

Replace any Firebase Phone Auth calls with the new service:

```dart
import 'package:auth_flutter/core/firebase/aws_sns_phone_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _snsService = AwsSnsPhoneService();
  String _phoneNumber = '';
  String _otp = '';
  bool _otpSent = false;

  void _sendOtp() async {
    try {
      await _snsService.sendOtp(
        phoneNumber: _phoneNumber,
        onSuccess: (phone) {
          setState(() => _otpSent = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent to $phone')),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  void _verifyOtp() async {
    try {
      final result = await _snsService.verifyOtp(
        phoneNumber: _phoneNumber,
        otp: _otp,
        onSuccess: (userId) {
          // Navigate to home screen
          print('Logged in as $userId');
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!_otpSent)
            Column(
              children: [
                TextField(
                  onChanged: (val) => _phoneNumber = val,
                  decoration: InputDecoration(hintText: '+919876543210'),
                ),
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: Text('Send OTP'),
                ),
              ],
            )
          else
            Column(
              children: [
                TextField(
                  onChanged: (val) => _otp = val,
                  decoration: InputDecoration(hintText: 'Enter 6-digit OTP'),
                ),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child: Text('Verify OTP'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
```

---

## Step 5: Test

### 5.1 Test on Device
```bash
flutter run -d 000173571000100
```

### 5.2 Send OTP
- Enter your phone number in E.164 format (e.g., `+919876543210`)
- Wait for SMS to arrive

### 5.3 Verify OTP
- Enter the 6-digit code from the SMS
- You should see a success message

---

## Troubleshooting

### OTP not received
- Ensure phone number is in E.164 format: `+<country-code><number>`
- Check that the phone number is verified in AWS SNS (Step 1.3)
- Check that AWS credentials are set correctly (Step 3.1)
- AWS free tier SMS is limited — check AWS billing

### Function deployment fails
- Run `firebase login` and select the correct project
- Ensure Node.js 20+ is installed
- Run `npm install` in the `functions` folder

### CORS errors
- Functions already have CORS enabled
- If still failing, check Firebase Console → Functions → Logs

---

## Costs

- **Free:** 1,000 SMS per month (AWS free tier, first 12 months)
- **After free tier:** ~$0.00645 per SMS (varies by country)

For 100 users signing up once: ~$0.65/month

---

## File Structure

```
auth_flutter/
├── functions/
│   ├── lib/
│   │   └── index.js (Cloud Functions)
│   └── package.json
├── lib/
│   ├── core/
│   │   └── firebase/
│   │       ├── firebase_phone_service.dart (OLD - can keep for reference)
│   │       └── aws_sns_phone_service.dart (NEW)
│   └── main.dart
└── pubspec.yaml
```

---

## Next Steps

1. Complete AWS setup (Steps 1-3)
2. Deploy Cloud Functions
3. Update your login screen to use `AwsSnsPhoneService`
4. Test on real device
5. Monitor costs in AWS billing dashboard

If you hit any issues, paste the error and I'll help debug!
