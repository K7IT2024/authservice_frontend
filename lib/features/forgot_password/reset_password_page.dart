import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/check_user_response.dart';

class ResetPasswordPage extends StatefulWidget {

  final CheckUserResponse response;

  const ResetPasswordPage({
    super.key,
    required this.response,
  });

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {

  final _formKey = GlobalKey<FormState>();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool loading = false;

  bool hidePassword = true;

  Future<void> resetPassword() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (newPasswordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text(
              "Passwords do not match"),
        ),

      );

      return;
    }

    setState(() {

      loading = true;

    });

    try {

      final response =
          await AuthApi.resetPassword(

        widget.response.userId!,

        newPasswordController.text,

        confirmPasswordController.text,

      );

      setState(() {

        loading = false;

      });

      if (!mounted) return;

      if (response.success) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(response.message),
          ),

        );

        context.go("/login");

      } else {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(response.message),
          ),

        );

      }

    } catch (e) {

      setState(() {

        loading = false;

      });

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),

      );

    }

  }

  @override
  void dispose() {

    newPasswordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Reset Password"),
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

                      color: Colors.green,

                    ),

                    const SizedBox(height: 20),

                    const Text(

                      "Create New Password",

                      style: TextStyle(

                        fontSize: 28,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 30),

                    TextFormField(

                      controller:
                          newPasswordController,

                      obscureText: hidePassword,

                      decoration: InputDecoration(

                        labelText:
                            "New Password",

                        prefixIcon:
                            const Icon(Icons.lock),

                        suffixIcon: IconButton(

                          icon: Icon(

                            hidePassword

                                ? Icons.visibility

                                : Icons.visibility_off,

                          ),

                          onPressed: () {

                            setState(() {

                              hidePassword =
                                  !hidePassword;

                            });

                          },

                        ),

                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return "Enter password";

                        }

                        if (value.length < 8) {

                          return "Minimum 8 characters";

                        }

                        return null;

                      },

                    ),

                    const SizedBox(height: 20),

                    TextFormField(

                      controller:
                          confirmPasswordController,

                      obscureText: hidePassword,

                      decoration: const InputDecoration(

                        labelText:
                            "Confirm Password",

                        prefixIcon:
                            Icon(Icons.lock),

                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return "Confirm password";

                        }

                        return null;

                      },

                    ),

                    const SizedBox(height: 30),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: loading
                            ? null
                            : resetPassword,

                        child: loading

                            ? const CircularProgressIndicator()

                            : const Text(
                                "Reset Password",
                              ),

                      ),

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