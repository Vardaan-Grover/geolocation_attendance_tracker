import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/services/firebase/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home/admin_home_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home/user_home_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/onboarding_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/auth/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? user;
  bool? hasSeenOnboarding;

  bool isLoading = true;

  FirebaseAuth.User? authUser = AuthFunctions.getCurrentUser();

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    });
  }

  Future<void> _fetchFirestoreUserIfLoggedIn() async {
    if (authUser != null) {
      final fetchedUser = await FirestoreFunctions.fetchUser(authUser!.uid);
      setState(() {
        user = fetchedUser;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _fetchFirestoreUserIfLoggedIn();
    print('Has Seen Onboarding: $hasSeenOnboarding');
    print('Is User logged in: $authUser');
  }

  @override
  Widget build(BuildContext context) {
    // Show splash/loading while checking onboarding status
    if (hasSeenOnboarding == null || isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!hasSeenOnboarding! && authUser == null) {
      return const OnboardingScreen();
    }
    if (hasSeenOnboarding! && authUser == null) {
      return const SignUpScreen();
    }
    if (!hasSeenOnboarding! && authUser != null) {
      if (user?.role == 'super-admin' || user?.role == 'admin') {
        return AdminHomeScreen(user!);
      } else if (user?.role == 'employee') {
        return UserHomeScreen(user!);
      }
    }
    if (hasSeenOnboarding! && authUser != null) {
      if (user?.role == 'super-admin' || user?.role == 'admin') {
        return AdminHomeScreen(user!);
      } else if (user?.role == 'employee') {
        return UserHomeScreen(user!);
      }
    }
    return OnboardingScreen();
  }
}
