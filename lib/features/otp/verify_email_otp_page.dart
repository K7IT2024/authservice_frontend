import 'dart:async';

import 'package:flutter/material.dart';

class VerifyEmailOtpPage extends StatefulWidget {
  final String email;


  const VerifyEmailOtpPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailOtpPage> createState() =>
      _VerifyEmailOtpPageState();
}

class _VerifyEmailOtpPageState
    extends State<VerifyEmailOtpPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController otpController =
      TextEditingController();

  bool loading = false;

  int secondsRemaining = 30;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    secondsRemaining = 30;

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (secondsRemaining == 0) {
          timer.cancel();
        } else {
          setState(() {
            secondsRemaining--;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 450,
            child: Card(
              elevation: 6,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const Icon(
                        Icons.mark_email_read,
                        size: 80,
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Email Verification",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        widget.email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: "Enter OTP",
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {

                          if (value == null ||
                              value.isEmpty) {
                            return "OTP is required";
                          }

                          if (value.length != 6) {
                            return "OTP must be 6 digits";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      Text(
                        secondsRemaining == 0
                            ? "You can resend OTP"
                            : "Resend OTP in $secondsRemaining sec",
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  // Lesson 2
                                },
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Verify OTP",
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: secondsRemaining == 0
                            ? () {
                                startTimer();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "OTP resend requested",
                                    ),
                                  ),
                                );

                                // Lesson 2
                              }
                            : null,
                        child: const Text(
                          "Resend OTP",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}