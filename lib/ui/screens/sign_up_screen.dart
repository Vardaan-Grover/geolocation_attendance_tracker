import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocation_attendance_tracker/providers/user_info_provider.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/admin_role_pathway.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home_screen.dart/user_home_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userForm = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        child: Padding(
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
                    selectedColor: Colors.white,
                    fillColor: colorScheme.primary,
                    children: const [
                      Text('Employer', textAlign: TextAlign.center),
                      Text('Employee', textAlign: TextAlign.center),
                    ],
                    isSelected: isSelected,
                    onPressed: (index) {
                      setState(() {
                        if (index == 0) {
                          isSelected = [true, false];
                          ref.read(userProvider.notifier).updateCompanyName('');
                        } else {
                          isSelected = [false, true];
                          ref
                              .read(userProvider.notifier)
                              .updateEmployeeCode('');
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).updateFullName(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    ref.read(userProvider.notifier).updateEmail(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (value) {
                    ref.read(userProvider.notifier).updatePassword(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                if (isSelected[1]) ...[
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Employee Code'),
                    onChanged: (value) {
                      ref.read(userProvider.notifier).updateEmployeeCode(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Employee UID';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (isSelected[1]) {
                        // If Employee role is selected, check the Employee UID
                        final employeeCode =
                            ref.read(userProvider)['employeeCode']!;
                        final companyId = await FirestoreFunctions
                            .findCompanyIdByEmployeeCode(employeeCode);

                        if (companyId != null) {
                          // Get current Firebase user
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            // Store user data in Firestore
                            final result = await FirestoreFunctions.createUser(
                              uid: user.uid,
                              fullName:
                                  ref.read(userProvider)['fullName'] ?? '',
                              role: 'employee',
                              associatedCompanyId: companyId,
                            );

                            if (result == 'success') {
                              // Navigate to User Home Screen if successful
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserHomeScreen(),
                                ),
                              );
                            } else {
                              // Show error if Firestore write fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error creating user: $result'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          // Show error if Employee UID is invalid
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Invalid Employee UID. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Navigate to Employer pathway
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CompanyScreen(),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Company already Registered? "),
                    GestureDetector(
                      onTap: () {
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
                          color: colorScheme.primary,
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
      ),
    );
  }
}
