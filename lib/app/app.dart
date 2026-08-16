import 'package:flutter/material.dart';
import '../common/theme/app_theme.dart';
import 'router.dart';

class IAMApp extends StatelessWidget {
  const IAMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "K7 IAM Portal",
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}