// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/admin_role_pathway.dart';

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
                  children: [
                    const Expanded(
                        child: Text('Employer', textAlign: TextAlign.center)),
                    const Expanded(
                        child: Text('Employee', textAlign: TextAlign.center)),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
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
                decoration: InputDecoration(labelText: 'Password'),
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
                  decoration: InputDecoration(labelText: 'Company UID'),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle sign-up logic here
                    if (isEmployer) {
                      print('Employer signed up: $name, $email');
                    } else {
                      print('Employee signed up: $name, $email, $companyUid');
                    }

                    // Navigate to the company screen after sign-up
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyScreen(),
                      ),
                    );
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
