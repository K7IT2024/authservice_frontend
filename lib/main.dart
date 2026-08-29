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
    // Try build-time dart-define first
    const webConfigRaw = String.fromEnvironment('FIREBASE_WEB_CONFIG', defaultValue: '');
    String effectiveConfig = webConfigRaw;

    // If not provided at build time, try runtime-injected global (firebase-config.js)
    if (effectiveConfig.isEmpty) {
      final dynamic runtime = js.context['__FIREBASE_WEB_CONFIG'];
      if (runtime != null) {
        try {
          effectiveConfig = js.context.callMethod('JSON.stringify', [runtime]);
        } catch (_) {
          try {
            effectiveConfig = runtime.toString();
          } catch (_) {
            effectiveConfig = '';
          }
        }
      }
    }

    if (effectiveConfig.isNotEmpty) {
      try {
        final Map<String, dynamic> conf = jsonDecode(effectiveConfig);
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: conf['apiKey'] ?? '',
            authDomain: conf['authDomain'],
            projectId: conf['projectId'] ?? '',
            storageBucket: conf['storageBucket'],
            messagingSenderId: conf['messagingSenderId'],
            appId: conf['appId'] ?? '',
            measurementId: conf['measurementId'],
          ),
        );
      } catch (e) {
        // Fallback
        await Firebase.initializeApp();
      }
    } else {
      await Firebase.initializeApp();
    }
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