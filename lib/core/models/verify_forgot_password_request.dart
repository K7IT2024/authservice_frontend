class VerifyForgotPasswordRequest {

  final int userId;
  final String otp;

  VerifyForgotPasswordRequest({
    required this.userId,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "otp": otp,
    };
  }
}