class RegisterResponse {

  final bool success;
  final String message;
  final String? email;

  RegisterResponse({

    required this.success,
    required this.message,
    this.email,

  });

  factory RegisterResponse.fromJson(
      Map<String, dynamic> json) {

    return RegisterResponse(

      success: json["success"] ?? false,
      message: json["message"] ?? "",
      email: json["email"],

    );

  }

}