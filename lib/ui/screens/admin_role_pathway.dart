import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocation_attendance_tracker/providers/user_info_provider.dart';
import 'package:geolocation_attendance_tracker/services/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home_screen/admin_home_screen.dart';

class CompanyScreen extends ConsumerWidget {
  const CompanyScreen({super.key});

  Future<void> _createCompany(
      BuildContext context, String companyName, WidgetRef ref) async {
    try {
      final userForm = ref.read(userProvider);

      await AuthFunctions.signUpWithEmailAndPassword(
          email: userForm['email'], password: userForm['password']);

      final currentUser = await AuthFunctions.getCurrentUser();

      if (currentUser != null) {
        final companyId = await FirestoreFunctions.createCompany(
          name: companyName,
        );
        print('Company ID: $companyId');

        // Assign the current user as Super Admin for the company
        final result = await FirestoreFunctions.createUser(
          uid: currentUser.uid,
          fullName: userForm['fullName'],
          role: "super-admin",
          associatedCompanyId: companyId,
        );

        if (result == "success") {
          final fetchedUser =
              await FirestoreFunctions.fetchUser(currentUser.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AdminHomeScreen(fetchedUser!)),
          );
        }
      } else {
        print('Error: currentUser is null');
      }
    } catch (e) {
      print('Error creating company: $e');
    }
  }

  Future<void> _joinCompany(
      BuildContext context, String adminCode, WidgetRef ref) async {
    try {
      final userForm = ref.read(userProvider);

      await AuthFunctions.signUpWithEmailAndPassword(
          email: userForm['email'], password: userForm['password']);

      final currentUser = await AuthFunctions.getCurrentUser();

      if (currentUser != null) {
        final result =
            await FirestoreFunctions.findCompanyByAdminCode(adminCode);

        if (result != null && !result.startsWith("Error")) {
          final companyId = result;

          final createUserResult = await FirestoreFunctions.createUser(
            uid: currentUser.uid,
            fullName: userForm['fullName'],
            role: "admin",
            associatedCompanyId: companyId,
          );

          if (createUserResult == "success") {
            final fetchedUser =
                await FirestoreFunctions.fetchUser(currentUser.uid);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminHomeScreen(fetchedUser!)),
            );
          } else {
            print('Error creating user in Firestore: $createUserResult');
          }
        } else {
          print('Error: $result'); // Handle the error if company not found
        }
      } else {
        print('Error: currentUser is null');
      }
    } catch (e) {
      print('Error joining company: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user information from provider
    final userForm = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Options"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Create a Company Button
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String companyName = '';

                      return AlertDialog(
                        title: const Text("Create a Company"),
                        content: TextField(
                          onChanged: (value) {
                            companyName = value;
                          },
                          decoration: const InputDecoration(
                              hintText: "Enter Company Name"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();

                              if (userForm['email'] != null &&
                                  userForm['password'] != null) {
                                // Use provider to read the current user details
                                await _createCompany(context, companyName, ref);
                              }
                            },
                            child: const Text("Submit"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Create a Company"),
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(0, 60), // Full width button with height 60
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Spacing between buttons
          // Join a Company Button
          Expanded(
            child: SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String companyUID = '';

                      return AlertDialog(
                        title: const Text("Join a Company"),
                        content: TextField(
                          onChanged: (value) {
                            companyUID = value;
                          },
                          decoration:
                              const InputDecoration(hintText: "Enter Admin ID"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();

                              // Call the join company method
                              if (companyUID.isNotEmpty) {
                                await _joinCompany(context, companyUID, ref);
                              }
                            },
                            child: const Text("Submit"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Join a Company"),
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(0, 60), // Full width button with height 60
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
