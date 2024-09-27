// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/services/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/admin_home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? password;
  String? role;

  void onLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final result = await AuthFunctions.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      final authUser = AuthFunctions.getCurrentUser();
      if (result == "success" && authUser != null) {
        final fetchedUser = await FirestoreFunctions.fetchUser(authUser.uid);
        if (fetchedUser != null) {
          final userRole = fetchedUser.role;
          if (userRole == "admin" || userRole == "super-admin") {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminHomeScreen(fetchedUser),
              ),
            );
          } else {
            //! Code to direct to Employee Home Screen
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('Login'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onLogin,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
