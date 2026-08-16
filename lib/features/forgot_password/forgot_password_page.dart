import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/check_user_response.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final _formKey = GlobalKey<FormState>();

  final usernameController =
      TextEditingController();

  bool loading = false;

  bool isEmailOrMobile(String value) {

    final emailRegex = RegExp(
        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

    final mobileRegex =
        RegExp(r'^\+?[0-9]{10,15}$');

    return emailRegex.hasMatch(value) ||
        mobileRegex.hasMatch(value);
  }

  Future<void> sendOtp() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      /// Check whether user exists
      CheckUserResponse response =
          await AuthApi.checkUser(
              usernameController.text.trim());

      if (!response.exists) {

        setState(() {
          loading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "User not found"),
          ),
        );

        return;
      }

      /// Send Forgot Password OTP
      final apiResponse =
          await AuthApi.forgotPassword(
              usernameController.text.trim());

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      if (apiResponse.success) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(apiResponse.message),
          ),

        );

        context.go(

          "/verify-forgot-password",

          extra: response,

        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(apiResponse.message),
          ),

        );

      }

    } catch (e) {

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
            "Forgot Password"),
      ),

      body: Center(

        child: Card(

          elevation: 5,

          child: SizedBox(

            width: 450,

            child: Padding(

              padding: const EdgeInsets.all(30),

              child: Form(

                key: _formKey,

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Icon(

                      Icons.lock_reset,

                      size: 70,

                      color: Colors.orange,

                    ),

                    const SizedBox(height: 20),

                    const Text(

                      "Forgot Password",

                      style: TextStyle(

                        fontSize: 28,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 10),

                    const Text(

                      "Enter your registered Email or Mobile",

                      textAlign: TextAlign.center,

                    ),

                    const SizedBox(height: 30),

                    TextFormField(

                      controller:
                          usernameController,

                      decoration:
                          const InputDecoration(

                        labelText:
                            "Email / Mobile",

                        prefixIcon:
                            Icon(Icons.person),

                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return "Enter Email or Mobile";

                        }

                        if (!isEmailOrMobile(
                            value)) {

                          return "Invalid Email/Mobile";

                        }

                        return null;

                      },

                    ),

                    const SizedBox(height: 30),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed:
                            loading
                                ? null
                                : sendOtp,

                        child: loading

                            ? const CircularProgressIndicator()

                            : const Text(
                                "Send OTP"),

                      ),

                    ),

                    const SizedBox(height: 20),

                    TextButton(

                      onPressed: () {

                        context.go("/login");

                      },

                      child: const Text(
                          "Back to Login"),

                    )

                  ],

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

}