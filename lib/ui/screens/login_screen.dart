// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? password;
  String? role; // 'admin', 'employee', 'superAdmin'

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
              // DropdownButtonFormField<String>(
              //   decoration: const InputDecoration(labelText: 'Role'),
              //   value: role,
              //   items: const [
              //     DropdownMenuItem(
              //       value: 'admin',
              //       child: Text('Employer as Admin'),
              //     ),
              //     DropdownMenuItem(
              //       value: 'employee',
              //       child: Text('Employee'),
              //     ),
              //     DropdownMenuItem(
              //       value: 'superAdmin',
              //       child: Text('Super Admin'),
              //     ),
              //   ],
              //   onChanged: (value) {
              //     setState(() {
              //       role = value;
              //     });
              //   },
              //   validator: (value) =>
              //       value == null ? 'Please select your role' : null,
              // ),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle login logic here
                    print('Role: $role, Email: $email');
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
