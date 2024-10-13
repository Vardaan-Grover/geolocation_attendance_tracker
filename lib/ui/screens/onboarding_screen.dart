// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/auth/sign_up_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  List<Widget> onboardingPages = [
    OnboardingPage(
      title: 'Welcome to Geo-Attendance',
      description: 'Track attendance based on location.',
      image: Icons.location_on,
    ),
    OnboardingPage(
      title: 'Secure and Accurate',
      description: 'No manual entries, 100% accurate geolocation.',
      image: Icons.security,
    ),
    OnboardingPage(
      title: 'Easy to Use',
      description: 'Simple interface to mark attendance.',
      image: Icons.touch_app,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                currentPage = index;
              });
            },
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return onboardingPages[index];
            },
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: onboardingPages.length,
                effect: const SwapEffect(
                  dotWidth: 10.0,
                  dotHeight: 10.0,
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey,
                  type: SwapType.yRotation,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async{
                if (currentPage == onboardingPages.length - 1) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasSeenOnboarding', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),);
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(currentPage == onboardingPages.length - 1
                  ? "Get Started"
                  : "Next"),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData image;

  OnboardingPage(
      {super.key,
      required this.title,
      required this.description,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            image,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
