import 'package:flutter/material.dart';

class EndPoints {

  static const String baseUrl =
      "http://localhost:8080/api/v1/auth";

  static const String checkUser =
      "$baseUrl/check-user";

  static const String register =
      "$baseUrl/register";

  static const String login =
      "$baseUrl/login";

  static const String sendEmailOtp =
      "$baseUrl/send-email-otp";

  static const String verifyEmailOtp =
      "$baseUrl/verify-email-otp";

  static const String sendMobileOtp =
      "$baseUrl/send-mobile-otp";

  static const String verifyMobileOtp =
      "$baseUrl/verify-mobile-otp";

  static const forgotPassword="$baseUrl/forgot-password";

  static const verifyForgotPasswordOtp="$baseUrl/verify-forgot-password-otp";

  static const resetPassword="$baseUrl/reset-password";

  static const userMe = "http://localhost:8080/api/v1/user/me";

  static const firebaseLogin="$baseUrl/firebase-login";

}