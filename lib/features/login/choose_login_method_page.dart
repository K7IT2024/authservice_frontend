import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/check_user_response.dart';

class ChooseLoginMethodPage extends StatefulWidget {
  final CheckUserResponse response;

  const ChooseLoginMethodPage({
    super.key,
    required this.response,
  });

  @override
  State<ChooseLoginMethodPage> createState() =>
      _ChooseLoginMethodPageState();
}

class _ChooseLoginMethodPageState
    extends State<ChooseLoginMethodPage> {

  String? selectedMethod;

  @override
  void initState() {
    super.initState();

    if (widget.response.methods.isNotEmpty) {
      selectedMethod = widget.response.methods.first;
    }
  }

  void continueLogin() {

    if (selectedMethod == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please choose a login method"),
        ),
      );

      return;
    }

    switch (selectedMethod) {

      case "PASSWORD":

        context.go(
          "/password-login",
          extra: widget.response,
        );

        break;

      case "EMAIL_OTP":

        context.go(
          "/email-otp",
          extra: widget.response,
        );

        break;

      case "MOBILE_OTP":

        context.go(
          "/mobile-login",
          extra: widget.response,
        );

        break;

      default:

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Login Method"),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Choose Login Method"),
      ),

      body: Center(

        child: Card(

          elevation: 5,

          child: SizedBox(

            width: 500,

            child: Padding(

              padding: const EdgeInsets.all(25),

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  const Icon(
                    Icons.security,
                    size: 70,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Select Login Method",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.response.username ?? "",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  ...widget.response.methods.map(

                    (method) => RadioListTile<String>(

                      title: Text(method),

                      value: method,

                      groupValue: selectedMethod,

                      onChanged: (value) {

                        setState(() {

                          selectedMethod = value;

                        });

                      },

                    ),

                  ),

                  const SizedBox(height: 30),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: continueLogin,

                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                    ),

                  ),

                ],

              ),

            ),

          ),

        ),

      ),

    );

  }
}