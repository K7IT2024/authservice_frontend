class ResetPasswordRequest {

  final int userId;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.userId,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };
  }
}