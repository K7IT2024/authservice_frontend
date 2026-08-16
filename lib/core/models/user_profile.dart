class UserProfile {

  final int id;

  final String firstName;

  final String lastName;

  final String email;

  final String mobile;

  final bool emailVerified;

  final bool mobileVerified;

  final bool active;

  UserProfile({

    required this.id,

    required this.firstName,

    required this.lastName,

    required this.email,

    required this.mobile,

    required this.emailVerified,

    required this.mobileVerified,

    required this.active,

  });

  factory UserProfile.fromJson(
      Map<String,dynamic> json){

    return UserProfile(

      id: json["id"],

      firstName: json["firstName"] ?? "",

      lastName: json["lastName"] ?? "",

      email: json["email"] ?? "",

      mobile: json["mobile"] ?? "",

      emailVerified:
          json["emailVerified"] ?? false,

      mobileVerified:
          json["mobileVerified"] ?? false,

      active:
          json["active"] ?? false,

    );

  }

}