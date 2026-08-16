import 'dart:convert';

import '../models/api_response.dart';
import '../models/check_user_response.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import 'api_client.dart';
import 'endpoints.dart';

class AuthApi {

  static Future<CheckUserResponse> checkUser(
    String username) async {

  final response = await ApiClient.post(
    EndPoints.checkUser,
    {
      "username": username,
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Unable to connect to server");
  }

  return CheckUserResponse.fromJson(
      jsonDecode(response.body));
}

  static Future<ApiResponse> sendEmailOtp(
      int userId) async {

    final response =
        await ApiClient.post(

      EndPoints.sendEmailOtp,

      {

        "userId": userId,

      },

    );

    return ApiResponse.fromJson(
      jsonDecode(response.body),
    );
  }

  static Future<ApiResponse> sendMobileOtp(
      int userId) async {

    final response =
        await ApiClient.post(

      EndPoints.sendMobileOtp,

      {

        "userId": userId,

      },

    );

    return ApiResponse.fromJson(
      jsonDecode(response.body),
    );
  }

  static Future<LoginResponse> verifyEmailOtp(

      int userId,

      String otp) async {

    final response =
        await ApiClient.post(

      EndPoints.verifyEmailOtp,

      {

        "userId": userId,

        "otp": otp,

      },

    );

    return LoginResponse.fromJson(
      jsonDecode(response.body),
    );

  }
  static Future<LoginResponse> verifyMobileOtp(

    int userId,

    String otp,

) async {

  final response = await ApiClient.post(

      EndPoints.verifyMobileOtp,

      {

        "userId": userId,

        "otp": otp,

      });

  return LoginResponse.fromJson(

      jsonDecode(response.body));

}
  static Future<LoginResponse> login(
      String username,
      String password,
  ) async {

    final response = await ApiClient.post(
      EndPoints.login,
      {
        "username": username,
        "password": password,
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final json = jsonDecode(response.body);

    print(json.runtimeType);
    print(json);

    return LoginResponse.fromJson(json);
  }

  static Future<ApiResponse> forgotPassword(
    String username) async {

  final response = await ApiClient.post(

    EndPoints.forgotPassword,

    {

      "username": username,

    },

  );

  return ApiResponse.fromJson(
      jsonDecode(response.body));
}
static Future<ApiResponse> verifyForgotPasswordOtp(

    int userId,

    String otp) async {

  final response = await ApiClient.post(

    EndPoints.verifyForgotPasswordOtp,

    {

      "userId": userId,

      "otp": otp,

    },

  );

  return ApiResponse.fromJson(
      jsonDecode(response.body));
}

static Future<ApiResponse> resetPassword(

    int userId,

    String newPassword,

    String confirmPassword) async {

  final response = await ApiClient.post(

    EndPoints.resetPassword,

    {

      "userId": userId,

      "newPassword": newPassword,

      "confirmPassword": confirmPassword,

    },

  );

  return ApiResponse.fromJson(
      jsonDecode(response.body));
}

static Future<UserProfile> getProfile() async {

  final response =
      await ApiClient.get(
      "/users/me");

  if(response.statusCode==200){

    return UserProfile.fromJson(
        jsonDecode(response.body));

  }

  throw Exception("Unable to load profile");

}
static Future<RegisterResponse> register(
    RegisterRequest request) async {

  final response = await ApiClient.post(

   EndPoints.register,

    request.toJson(),

  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {

    return RegisterResponse.fromJson(

      jsonDecode(response.body),

    );

  }

  throw Exception("Registration Failed");

}
static Future<LoginResponse> firebaseLogin(
    String idToken) async {

  final response = await ApiClient.post(

    EndPoints.firebaseLogin,

    {

      "idToken": idToken,

    },

  );

  if (response.statusCode == 200) {

    return LoginResponse.fromJson(
      jsonDecode(response.body),
    );

  }

  throw Exception("Firebase Login Failed");

}

}