class RegisterRequest {

  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;

  RegisterRequest({

    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,

  });

  Map<String, dynamic> toJson() {

    return {

      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobile": mobile,
      "password": password,

    };

  }

}