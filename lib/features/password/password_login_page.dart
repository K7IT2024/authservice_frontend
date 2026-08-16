import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/check_user_response.dart';

class PasswordLoginPage extends StatefulWidget {
  final CheckUserResponse response;

  const PasswordLoginPage({
    super.key,
    required this.response,
  });

  @override
  State<PasswordLoginPage> createState() =>
      _PasswordLoginPageState();
}

class _PasswordLoginPageState
    extends State<PasswordLoginPage> {

  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();

  bool loading = false;

  bool obscurePassword = true;

  Future<void> login() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final response = await AuthApi.login(

        widget.response.username ?? "",

        passwordController.text,

      );

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      if (response.success) {

        context.go("/dashboard");

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
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Password Login"),

      ),

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

                    const Icon(
                      Icons.lock,
                      size: 70,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 20),

                    Text(

                      widget.response.username ?? "",

                      style: const TextStyle(
                        fontSize: 18,
                      ),

                    ),

                    const SizedBox(height: 30),

                    TextFormField(

                      controller: passwordController,

                      obscureText: obscurePassword,

                      decoration: InputDecoration(

                        labelText: "Password",

                        prefixIcon: const Icon(Icons.lock),

                        suffixIcon: IconButton(

                          icon: Icon(

                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),

                          onPressed: () {

                            setState(() {

                              obscurePassword =
                                  !obscurePassword;

                            });

                          },

                        ),

                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return "Enter Password";

                        }

                        return null;

                      },

                    ),

                    const SizedBox(height: 30),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed:
                            loading ? null : login,

                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text("Login"),

                      ),

                    ),

                    TextButton(

                      onPressed: () {

                        context.go("/forgot-password");

                      },

                      child: const Text(
                          "Forgot Password?"),

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