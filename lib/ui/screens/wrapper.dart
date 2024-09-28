

import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/onboarding_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool? hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  // Check if the user has already seen the onboarding screen
  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash/loading while checking onboarding status
    if (hasSeenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return hasSeenOnboarding! ? const SignUpScreen() : const OnboardingScreen();
  }
}
