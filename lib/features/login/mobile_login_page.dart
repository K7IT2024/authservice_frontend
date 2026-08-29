import 'dart:async';

import 'package:auth_flutter/core/firebase/firebase_phone_service.dart';
import 'package:auth_flutter/core/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({super.key});

  @override
  State<MobileLoginPage> createState() =>
      _MobileLoginPageState();
}

class _MobileLoginPageState
    extends State<MobileLoginPage> {

  final FirebasePhoneService _phoneService = FirebasePhoneService();

  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController otpController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool otpSent = false;

  bool loading = false;

  bool obscureOtp = false;

  String? verificationId;
  int resendSeconds = 30;

  Timer? resendTimer;

bool canResend = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

  resendTimer?.cancel();

  mobileController.dispose();

  otpController.dispose();

  super.dispose();

}

  void showLoading() {

    setState(() {

      loading = true;

    });

  }

  void hideLoading() {

    setState(() {

      loading = false;

    });

  }

  void showMessage(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(message),

      ),

    );

  }
  void startResendTimer() {

  resendSeconds = 30;

  canResend = false;

  resendTimer?.cancel();

  resendTimer = Timer.periodic(

    const Duration(seconds: 1),

    (timer) {

      if (resendSeconds == 0) {

        timer.cancel();

        setState(() {

          canResend = true;

        });

      } else {

        setState(() {

          resendSeconds--;

        });

      }

    },

  );

}
  Future<void> sendOtp() async {

  if (mobileController.text.trim().isEmpty) {

    showMessage("Enter Mobile Number");

    return;

  }

  showLoading();

  try {

    final rawPhone = mobileController.text.trim();
    final phoneNumber = rawPhone.startsWith('+') ? rawPhone : '+91$rawPhone';

    await _phoneService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (id) {

        verificationId = id;

        otpSent = true;

        startResendTimer();

        hideLoading();

        setState(() {});

        showMessage("OTP Sent Successfully");

      },

      onError: (error) {

        hideLoading();

        showMessage(error);

      },

    );

  } catch (e) {

    hideLoading();

    showMessage(e.toString());

  }

}

Future<void> verifyOtp() async {

  if (otpController.text.trim().isEmpty) {

    showMessage("Enter OTP");

    return;

  }

  showLoading();

  try {

    //--------------------------------------------------
    // Verify OTP with Firebase
    //--------------------------------------------------

    // Verify OTP via backend (AWS SNS)
    final login =
        await _phoneService.verifyOtp(
      otpController.text.trim(),
    );

    hideLoading();

    if (login.success) {
      await SecureStorageService.saveTokens(
        accessToken: login.accessToken,
        refreshToken: login.refreshToken,
      );

      showMessage("Login Successful");

      if (mounted) {
        context.go("/dashboard");
      }
    } else {
      showMessage(login.message);
    }

  } catch (e) {

    hideLoading();

    showMessage(e.toString());

  }

}
@override
Widget build(BuildContext context) {

  return Scaffold(

    appBar: AppBar(
      title: const Text("Mobile Login"),
      centerTitle: true,
    ),

    body: Stack(

      children: [

        Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: SizedBox(

              width: 420,

              child: Card(

                elevation: 6,

                shape: RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(15),

                ),

                child: Padding(

                  padding:
                      const EdgeInsets.all(25),

                  child: Form(

                    key: _formKey,

                    child: Column(

                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [

                         const CircleAvatar(

                          radius: 45,

                          backgroundColor: Colors.blue,

                          child: Icon(

                            Icons.lock_person,

                            size: 50,

                            color: Colors.white,

                          ),

                        ),

                        const SizedBox(height: 20),

                        const Text(

                          "K7 IAM",

                          textAlign: TextAlign.center,

                          style: TextStyle(

                            fontSize: 30,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 10),

                        const Text(

                          "Secure Mobile Authentication",

                          textAlign: TextAlign.center,

                          style: TextStyle(

                            color: Colors.grey,

                            fontSize: 16,

                          ),

                        ),

                        const SizedBox(height: 30),
                        TextFormField(

                          controller: mobileController,

                          keyboardType: TextInputType.phone,

                          enabled: !otpSent,

                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return "Enter Mobile Number";
                            }

                            if (value.length != 10) {
                              return "Enter Valid Mobile Number";
                            }

                            return null;
                          },

                         decoration: const InputDecoration(

                          labelText: "Mobile Number",

                          hintText: "9876543210",

                          prefixIcon: Icon(Icons.phone_android),

                          prefixText: "+91 ",

                          border: OutlineInputBorder(),

                        ),

                        ),

                        const SizedBox(height: 20),

                        if (otpSent)


                          TextFormField(

                            controller: otpController,

                            keyboardType: TextInputType.number,

                            validator: (value) {

                              if (value == null || value.isEmpty) {

                                return "Enter OTP";

                              }

                              if (value.length != 6) {

                                return "OTP should contain 6 digits";

                              }

                              return null;

                            },

                            decoration: InputDecoration(

                              labelText: "Enter OTP",

                              prefixIcon: const Icon(Icons.lock),

                              border: const OutlineInputBorder(),

                              suffixIcon: IconButton(

                                icon: Icon(

                                  obscureOtp
                                      ? Icons.visibility
                                      : Icons.visibility_off,

                                ),

                                onPressed: () {

                                  setState(() {

                                    obscureOtp = !obscureOtp;

                                  });

                                },

                              ),

                            ),

                            obscureText: obscureOtp,

                          ),

                        const SizedBox(height: 30),

                        SizedBox(

                          height: 50,

                          child: ElevatedButton(

                           onPressed: () {

                              if (!_formKey.currentState!.validate()) {

                                return;

                              }

                              if (otpSent) {

                                verifyOtp();

                              } else {

                                sendOtp();

                              }

                            },

                            child: Text(

                              otpSent
                                  ? "Verify OTP"
                                  : "Send OTP",

                            ),

                          ),

                        ),

                        const SizedBox(height: 10),

                        if (otpSent)

                          Center(

                            child: canResend

                                ? TextButton(

                                    onPressed: sendOtp,

                                    child: const Text(

                                      "Resend OTP",

                                    ),

                                  )

                                : Text(

                                    "Resend OTP in $resendSeconds sec",

                                    style: const TextStyle(

                                      color: Colors.grey,

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

        ),

        if (loading)

          Container(

            color: Colors.black26,

            child: const Center(

              child: CircularProgressIndicator(),

            ),

          ),

      ],

    ),

  );

}
}
