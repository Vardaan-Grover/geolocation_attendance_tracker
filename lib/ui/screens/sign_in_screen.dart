import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocation_attendance_tracker/providers/user_info_provider.dart';

import 'package:geolocation_attendance_tracker/ui/screens/admin_role_pathway.dart';
import 'package:geolocation_attendance_tracker/ui/screens/login_screen.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use provider to access and update form values
    final userForm = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  constraints: BoxConstraints(
                      minHeight: 40,
                      minWidth: (MediaQuery.of(context).size.width - 36) / 2),
                  children: const [
                    Text('Employer', textAlign: TextAlign.center),
                    Text('Employee', textAlign: TextAlign.center),
                  ],
                  //! WRONG LOGIC. MAKE WIDGET STATEFUL AND USE OLD isEmployee VARIABLE TO HANDLE THIS
                  isSelected: [
                    userForm['companyName'] != null,
                    userForm['employeeCode'] != null,
                  ],
                  onPressed: (index) {
                    if (index == 0) {
                      ref.read(userProvider.notifier).updateCompanyName('');
                    } else {
                      ref.read(userProvider.notifier).updateEmployeeCode('');
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  ref.read(userProvider.notifier).updateFullName(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  ref.read(userProvider.notifier).updateEmail(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  ref.read(userProvider.notifier).updatePassword(value);
                },
              ),
              if (userForm['companyName'] == null) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Employee UID'),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).updateEmployeeCode(value);
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Navigate to the user homepage screen for employee
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompanyScreen(),
                    ),
                  );
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
