import 'dart:convert';
import 'package:http/http.dart' as http;

class AwsSnsPhoneService {
  final String baseUrl;

  AwsSnsPhoneService({required this.baseUrl});

  String _normalizePhone(String phoneNumber) {
    String formatted = phoneNumber.trim();
    if (!formatted.startsWith('+')) {
      if (formatted.length == 10) {
        formatted = '+91$formatted';
      } else {
        formatted = '+$formatted';
      }
    }
    return formatted;
  }

  Future<int> sendOtp({
    required String phoneNumber,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final formattedNumber = _normalizePhone(phoneNumber);
      print('📱 Sending OTP to: $formattedNumber via AWS SNS');

      final uri = Uri.parse('$baseUrl/send-otp');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': formattedNumber}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ OTP sent successfully!');
        print('Expires in: ${data['expiresIn']} seconds');
        onSuccess(formattedNumber);
        return data['expiresIn'] ?? 600;
      }

      final message = data['error'] ?? 'Failed to send OTP';
      throw Exception(message);
    } catch (e) {
      print('❌ Error sending OTP: $e');
      onError('Failed to send OTP: ${e.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final formattedNumber = _normalizePhone(phoneNumber);
      print('🔑 Verifying OTP: $otp');

      final uri = Uri.parse('$baseUrl/verify-otp');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': formattedNumber, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ OTP verified successfully!');
        print('User ID: ${data['userId']}');
        onSuccess(data['userId']);
        return {'success': true, 'userId': data['userId']};
      }

      final message = data['error'] ?? 'Failed to verify OTP';
      throw Exception(message);
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      onError('OTP verification failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<int> resendOtp({
    required String phoneNumber,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final formattedNumber = _normalizePhone(phoneNumber);
      print('📱 Resending OTP to: $formattedNumber');

      final uri = Uri.parse('$baseUrl/resend-otp');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': formattedNumber}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ OTP resent successfully!');
        onSuccess(formattedNumber);
        return data['expiresIn'] ?? 600;
      }

      final message = data['error'] ?? 'Failed to resend OTP';
      throw Exception(message);
    } catch (e) {
      print('❌ Error resending OTP: $e');
      onError('Failed to resend OTP: ${e.toString()}');
      rethrow;
    }
  }
}
