import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/login_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/onboarding_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/sign_in_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006BFF),
              secondary: Color(0xFF476788),
            )),
        debugShowCheckedModeBanner: false,
        home: const LoginPage());
  }
}
