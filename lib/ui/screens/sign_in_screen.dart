import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/admin_role_pathway.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home_screen.dart/user_home_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/login_screen.dart'; // Import the login page

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  bool isEmployer = true; // Toggle between Employee and Employer
  String? name;
  String? email;
  String? password;
  String? companyUid; // Only for employee
  String? companyName; // Only for Super Admin

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  constraints: BoxConstraints(
                      minHeight: 40,
                      minWidth: (MediaQuery.of(context).size.width - 36) / 2),
                  // ignore: sort_child_properties_last
                  children: const [
                    Text('Employer', textAlign: TextAlign.center),
                    Text('Employee', textAlign: TextAlign.center),
                  ],
                  isSelected: [isEmployer, !isEmployer],
                  onPressed: (index) {
                    setState(() {
                      isEmployer = index == 0;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value;
                    },
                  ),
                ],
              ),
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
              if (!isEmployer) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Company UID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company UID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    companyUid = value;
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle sign-up logic here
                    if (isEmployer) {
                      print('Employer signed up: $name, $email');
                      // Navigate to the company screen for employer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompanyScreen(),
                        ),
                      );
                    } else {
                      print('Employee signed up: $name, $email, $companyUid');
                      // Navigate to the user homepage screen for employee
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserHomeScreen(),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
              const Spacer(), // Pushes the following Row to the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Company already Registered? "),
                  GestureDetector(
                    onTap: () {
                      // Navigate to LoginPage when clicked
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: colorScheme.primary, // Use theme color for link
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
