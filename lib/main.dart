import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/auth_provider.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(

    ChangeNotifierProvider(

      create: (_)=>AuthProvider(),

      child: const IAMApp(),

    ),

  );

}