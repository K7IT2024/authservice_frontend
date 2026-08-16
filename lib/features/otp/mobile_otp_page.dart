import 'package:auth_flutter/core/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/check_user_response.dart';

class MobileOtpPage extends StatefulWidget {

  final CheckUserResponse response;

  const MobileOtpPage({
    super.key,
    required this.response,
  });

  @override
  State<MobileOtpPage> createState() => _MobileOtpPageState();
}

class _MobileOtpPageState extends State<MobileOtpPage> {

  final otpController = TextEditingController();

  bool loading = false;

  bool otpSent = false;

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  Future<void> sendOtp() async {

    setState(() {
      loading = true;
    });

    try {

      final result =
              await AuthApi.sendMobileOtp(
               widget.response.userId!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );

      otpSent = true;

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    setState(() {
      loading = false;
    });

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

      final login =
         await AuthApi.verifyMobileOtp(

        widget.response.userId!,

        otpController.text,
    );
      await SecureStorageService.saveTokens(

        accessToken: login.accessToken!,

        refreshToken: login.refreshToken!,

      );

      if (!mounted) return;

      context.go("/dashboard");

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Mobile Verification"),
      ),

      body: Center(

        child: SizedBox(

          width: 420,

          child: Card(

            child: Padding(

              padding: const EdgeInsets.all(25),

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  const Icon(
                    Icons.email,
                    size: 70,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Mobile OTP Verification",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(

                    controller: otpController,

                    keyboardType: TextInputType.number,

                    maxLength: 6,

                    decoration: const InputDecoration(
                      labelText: "Enter OTP",
                    ),

                  ),

                  const SizedBox(height: 25),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: loading
                          ? null
                          : verifyOtp,

                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Verify"),

                    ),

                  ),

                  TextButton(

                    onPressed: sendOtp,

                    child: const Text("Resend OTP"),

                  )

                ],

              ),

            ),

          ),

        ),

      ),

    );

  }

}