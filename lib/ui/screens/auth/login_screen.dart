import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/services/firebase/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home/admin_home_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home/user_home_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/auth/sign_up_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? email;
  String? password;
  String? role;
  bool isLoading = false; // Loading indicator state
  String? errorMessage; // Error message state

  void onLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true; // Start showing loading indicator
        errorMessage = null; // Clear any previous errors
      });

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
          } else if (userRole == "employee") {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UserHomeScreen(fetchedUser),
              ),
            );
          } else {
            setState(() {
              errorMessage = 'Unknown role assigned to the user.';
            });
          }
        } else {
          setState(() {
            errorMessage = 'User not found in the database.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Login failed. Please check your email and password.';
        });
      }

      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Login'))),
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
              if (errorMessage != null) // Show error message if present
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              isLoading // Show CircularProgressIndicator if loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLogin,
                        child: const Text('Login'),
                      ),
                    ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
