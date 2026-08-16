class CheckUserRequest {
  final String username;

  CheckUserRequest({
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
    };
  }
}