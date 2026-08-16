class CheckUserResponse {
  final bool exists;
  final int? userId;
  final List<String> methods;
  final String? username;
  final String? message;

  CheckUserResponse({
    required this.exists,
    required this.userId,
    required this.methods,
    this.username,
    this.message,
  });

  factory CheckUserResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserResponse(
      exists: json["exists"] ?? false,
      userId: json["userId"] == null
          ? null
          : int.parse(json["userId"].toString()),
      methods: (json["methods"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      username: json["username"],
      message: json["message"],
    );
  }
}