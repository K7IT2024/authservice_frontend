import 'package:auth_flutter/core/api/auth_api.dart';

class FirebasePhoneService {
  // Adapter: replaced Firebase implementation with backend API calls
  // Keeps the same interface so UI code doesn't need large changes.

  int? _lastUserId;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // phoneNumber expected in formats like +91xxxxxxxxxx or 10-digit
      // Use backend checkUser to find userId by phone/email
      final username = phoneNumber.replaceAll('+', '');

      final check = await AuthApi.checkUser(username);

      if (!check.exists) {
        onError('User not found');
        return;
      }

      _lastUserId = check.userId;

      final res = await AuthApi.sendMobileOtp(check.userId!);

      if (res.success) {
        onCodeSent('OK');
      } else {
        onError(res.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<String> verifyOtp(String otp) async {
    if (_lastUserId == null) throw Exception('No OTP request in progress');

    final login = await AuthApi.verifyMobileOtp(_lastUserId!, otp);

    if (login.success) {
      return login.accessToken ?? '';
    }

    throw Exception(login.message ?? 'OTP verification failed');
  }
}