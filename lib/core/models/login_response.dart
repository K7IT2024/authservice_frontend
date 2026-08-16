class LoginResponse {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json["success"] as bool,
      message: json["message"] as String,
      accessToken: json["accessToken"] as String,
      refreshToken: json["refreshToken"] as String,
    );
  }
}