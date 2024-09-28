import 'package:flutter/material.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( 
          title: Text("User Home Screeen"),
        ),
        body: const Center(child: Text("User Home Screen")));
  }
}
