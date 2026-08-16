import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/check_user_response.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController =
      TextEditingController();

  bool loading = false;

  bool isEmailOrMobile(String value) {

    final emailRegex = RegExp(
        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

    final mobileRegex = RegExp(r'^[0-9]{10}$');

    return emailRegex.hasMatch(value) ||
        mobileRegex.hasMatch(value);
  }

  Future<void> continueLogin() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      CheckUserResponse response =
          await AuthApi.checkUser(
              usernameController.text.trim());

      setState(() {
        loading = false;
      });

      if (!response.exists) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Email/Mobile not registered"),
          ),
        );

        return;
      }

      if (!mounted) return;

      context.go(
        "/choose-login",
        extra: response,
      );

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

      body: Center(

        child: Card(

          child: SizedBox(

            width: 450,

            child: Padding(

              padding: const EdgeInsets.all(30),

              child: Form(

                key: _formKey,

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const FlutterLogo(size: 70),

                    const SizedBox(height: 20),

                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextFormField(

                      controller: usernameController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            "Email or Mobile Number",
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return "Enter Email";
                        }

                        if (!isEmailOrMobile(value)) {
                          return "Invalid Email/Mobile";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed:
                            loading ? null : continueLogin,

                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                "Continue",
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(

                      onPressed: () {
                        context.go("/register");
                      },

                      child: const Text(
                          "Create Account"),
                    ),
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