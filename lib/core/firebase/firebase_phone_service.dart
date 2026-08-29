import 'package:auth_flutter/core/api/auth_api.dart';
import 'package:auth_flutter/core/models/login_response.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          final user = _auth.currentUser;
          if (user == null) {
            await _auth.signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_firebaseErrorMessage(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
      );
    } on FirebaseAuthException catch (e) {
      onError(_firebaseErrorMessage(e));
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<LoginResponse> verifyOtp(String otp) async {
    if (_verificationId == null || _verificationId!.isEmpty) {
      throw Exception('No OTP verification in progress');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to fetch Firebase token');
    }

    return AuthApi.firebaseLogin(idToken);
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'captcha-check-failed':
        return 'Captcha verification failed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Firebase authentication failed.';
    }
  }
}