import 'package:auth_flutter/core/api/auth_api.dart';
import 'package:auth_flutter/core/models/login_response.dart';

class BackendPhoneService {
  int? _lastUserId;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
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

  Future<LoginResponse> verifyOtp(String otp) async {
    if (_lastUserId == null) throw Exception('No OTP request in progress');

    final login = await AuthApi.verifyMobileOtp(_lastUserId!, otp);

    if (login.success) return login;

    throw Exception(login.message ?? 'OTP verification failed');
  }
}
