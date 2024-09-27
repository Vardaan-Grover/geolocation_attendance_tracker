import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/login_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/onboarding_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SignUpPage());
  }
}
