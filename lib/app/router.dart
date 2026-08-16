import 'package:auth_flutter/features/forgot_password/forgot_password_page.dart';
import 'package:auth_flutter/features/forgot_password/reset_password_page.dart';
import 'package:auth_flutter/features/forgot_password/verify_forgot_password_page.dart';
import 'package:auth_flutter/features/otp/email_otp_page.dart';
import 'package:auth_flutter/features/otp/mobile_otp_page.dart';
import 'package:auth_flutter/features/otp/verify_email_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_page.dart';
import '../features/login/login_page.dart';
import '../features/register/register_page.dart';
import '../features/welcome/welcome_page.dart';
import '../core/models/check_user_response.dart';
import '../features/login/choose_login_method_page.dart';
import '../features/password/password_login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import 'package:auth_flutter/features/login/mobile_login_page.dart';
final router = GoRouter(

  initialLocation: "/",

  routes: [

    GoRoute(

      path: "/",

      builder: (_, __) => const SplashPage(),

    ),

    GoRoute(

      path: "/welcome",

      builder: (_, __) => const WelcomePage(),

    ),

     GoRoute(
      path: "/choose-login",
      builder: (context, state) {

      final response = state.extra as CheckUserResponse;
       return ChooseLoginMethodPage(
      response: response,
    );

  },
),
  GoRoute(
  path: "/password-login",
  builder: (context, state) {

    print("state.extra = ${state.extra}");

    final response = state.extra;

    if (response == null) {
      return const Scaffold(
        body: Center(
          child: Text("state.extra is NULL"),
        ),
      );
    }

    return PasswordLoginPage(
      response: response as CheckUserResponse,
    );
  },
),
GoRoute(

 path: "/email-otp",

 builder: (context,state){

   final response =
       state.extra as CheckUserResponse;

   return EmailOtpPage(
       response: response);

 },

),

GoRoute(

 path: "/mobile-otp",

 builder: (context,state){

   final response =
       state.extra as CheckUserResponse;

   return MobileOtpPage(
       response: response);

 },

),
    GoRoute(

      path: "/dashboard",

      builder: (_, __) =>
          const DashboardPage(),

    ),
    GoRoute(

      path: "/login",

      builder: (_, __) => const LoginPage(),

    ),

    GoRoute(

      path: "/register",

      builder: (_, __) => const RegisterPage(),

    ),
      GoRoute(
      path: "/forgot-password",
      builder: (_, __) =>
          const ForgotPasswordPage(),
    ),
    GoRoute(

  path: "/verify-forgot-password",

  builder: (context, state) {

    final response =
        state.extra as CheckUserResponse;

    return VerifyForgotPasswordPage(

      response: response,

    );

  },

),
  GoRoute(

  path: "/reset-password",

  builder: (context, state) {

    final response =
        state.extra as CheckUserResponse;

    return ResetPasswordPage(

      response: response,

    );

  },

),
GoRoute(

  path: "/verify-email-otp",

  builder: (context, state) {

    final email = state.extra as String;

    return VerifyEmailOtpPage(
      email: email,
    );

  },

),
  GoRoute(

    path: "/mobile-login",

    builder: (context, state) =>
        const MobileLoginPage(),

  ),
  ],

  errorBuilder: (_, state) {

    return Scaffold(

      body: Center(

        child: Text(

          "Page Not Found\n${state.uri}",

        ),

      ),

    );

  },
  

);