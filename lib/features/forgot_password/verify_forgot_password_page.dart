import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/check_user_response.dart';

class VerifyForgotPasswordPage extends StatefulWidget {

  final CheckUserResponse response;

  const VerifyForgotPasswordPage({
    super.key,
    required this.response,
  });

  @override
  State<VerifyForgotPasswordPage> createState() =>
      _VerifyForgotPasswordPageState();
}

class _VerifyForgotPasswordPageState
    extends State<VerifyForgotPasswordPage> {

  final otpController = TextEditingController();

  bool loading = false;

  int seconds = 30;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {

    seconds = 30;

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        if (seconds == 0) {

          timer.cancel();

        } else {

          setState(() {

            seconds--;

          });

        }

      },
    );

  }

  @override
  void dispose() {

    timer?.cancel();

    otpController.dispose();

    super.dispose();

  }

  Future<void> verifyOtp() async {

    if (otpController.text.length != 6) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Enter valid OTP"),
        ),

      );

      return;

    }

    setState(() {

      loading = true;

    });

    try {

      final response =
          await AuthApi.verifyForgotPasswordOtp(

        widget.response.userId!,

        otpController.text,

      );

      setState(() {

        loading = false;

      });

      if (!mounted) return;

      if (response.success) {

        context.go(

          "/reset-password",

          extra: widget.response,

        );

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

  Future<void> resendOtp() async {

    await AuthApi.forgotPassword(

      widget.response.username ?? "",

    );

    startTimer();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text("OTP Sent Successfully"),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Verify OTP"),

      ),

      body: Center(

        child: Card(

          elevation: 5,

          child: SizedBox(

            width: 450,

            child: Padding(

              padding: const EdgeInsets.all(30),

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  const Icon(

                    Icons.lock_clock,

                    size: 70,

                    color: Colors.blue,

                  ),

                  const SizedBox(height: 20),

                  const Text(

                    "Verify OTP",

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

                  TextField(

                    controller: otpController,

                    keyboardType: TextInputType.number,

                    maxLength: 6,

                    decoration: const InputDecoration(

                      labelText: "Enter OTP",

                      prefixIcon: Icon(Icons.password),

                    ),

                  ),

                  const SizedBox(height: 25),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed:
                          loading ? null : verifyOtp,

                      child: loading

                          ? const CircularProgressIndicator()

                          : const Text("Verify OTP"),

                    ),

                  ),

                  const SizedBox(height: 25),

                  seconds == 0

                      ? TextButton(

                          onPressed: resendOtp,

                          child: const Text("Resend OTP"),

                        )

                      : Text(

                          "Resend OTP in $seconds seconds",

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