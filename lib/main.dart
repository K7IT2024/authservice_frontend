import 'dart:convert';
import 'dart:js' as js;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Temporarily skip Firebase initialization on web to restore prior working state.
    // This avoids runtime crashes when FIREBASE_WEB_CONFIG is missing or malformed.
    print('Skipping Firebase initialization on web (no config).');
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const IAMApp(),
    ),
  );
}