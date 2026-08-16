# AWS SNS OTP Setup (No Firebase Required)

This project now supports a standalone AWS SNS backend for SMS OTP without Firebase Cloud Functions.

## What changed

- `aws_backend/server.js`: a simple Express server that sends OTPs through AWS SNS.
- `lib/core/firebase/aws_sns_phone_service.dart`: updated to call the new REST backend.
- No Firebase callable functions are required.

## How to run the backend

1. Install dependencies:
```bash
cd d:\LoginService\frontend\auth_flutter\aws_backend
npm install
```

2. Create a `.env` file from `.env.example`:
```bash
copy .env.example .env
```

3. Fill in your AWS credentials:
```text
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
AWS_REGION=ap-south-1
PORT=3000
```

4. Start the server:
```bash
npm start
```

5. The backend will run at:
```text
http://localhost:3000
```

## How to configure the Flutter app

Use `AwsSnsPhoneService` with your backend URL.

Example:
```dart
final awsService = AwsSnsPhoneService(baseUrl: 'http://10.0.2.2:3000');
```

- For Android emulator use `10.0.2.2`.
- For physical devices, use your PC's LAN IP, for example: `http://192.168.1.100:3000`.

## Flutter code usage

```dart
final smsService = AwsSnsPhoneService(baseUrl: 'http://10.0.2.2:3000');

await smsService.sendOtp(
  phoneNumber: '+919876543210',
  onSuccess: (phone) => print('OTP sent to $phone'),
  onError: (err) => print('Error: $err'),
);

await smsService.verifyOtp(
  phoneNumber: '+919876543210',
  otp: '123456',
  onSuccess: (userId) => print('Verified user $userId'),
  onError: (err) => print('Error: $err'),
);
```

## Notes

- This backend uses a file-based OTP store (`aws_backend/otp_store.json`). It is simple and works for development.
- For production, replace storage with a proper database (MongoDB, PostgreSQL, MySQL, DynamoDB, etc.).
- Make sure your AWS SNS phone number is allowed in the region and able to send SMS to the target country.
- This solution does not use Firebase for OTP delivery or backend routing.
