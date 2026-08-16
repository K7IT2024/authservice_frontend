import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class BackendAuthService {
  static const String baseUrl = 'http://localhost:8080/api/v1';

  /// Send OTP via backend (AWS SNS)
  Future<void> sendMobileOtp({
    required int userId,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      print("📱 Requesting OTP from backend for userId: $userId");

      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-mobile-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          print("✅ OTP sent successfully!");
          onSuccess(jsonResponse['message'] ?? 'OTP sent successfully');
        } else {
          print("❌ Backend returned error: ${jsonResponse['message']}");
          onError(jsonResponse['message'] ?? 'Failed to send OTP');
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        onError('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Exception during sendMobileOtp: $e");
      onError("Failed to send OTP: ${e.toString()}");
    }
  }

  /// Verify OTP sent via backend
  Future<String> verifyMobileOtp({
    required int userId,
    required String otp,
  }) async {
    try {
      print("🔑 Verifying OTP with backend");

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-mobile-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'otp': otp,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      print("📡 Verify Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          print("✅ OTP verified successfully!");
          final accessToken = jsonResponse['accessToken'];
          print("✅ Access Token: ${accessToken?.substring(0, 20)}...");
          return accessToken ?? '';
        } else {
          print("❌ OTP verification failed: ${jsonResponse['message']}");
          throw Exception(jsonResponse['message'] ?? 'OTP verification failed');
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        throw Exception('OTP verification failed: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Exception during verifyMobileOtp: $e");
      rethrow;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
