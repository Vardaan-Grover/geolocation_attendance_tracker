import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocation_attendance_tracker/services/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home_screen.dart/admin_home_screen.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  Future<void> _createCompany(
      BuildContext context, String uid, String companyName) async {
    try {
      // Create a new company document in Firestore
      final companyId = await FirestoreFunctions.createCompany(name: companyName);

      // Get current user
      final currentUser =AuthFunctions.getCurrentUser();

      if (currentUser != null) {
        // Assign the current user as the Super Admin for the new company
        await FirestoreFunctions.createUser(
          uid: currentUser.uid,
          fullName: currentUser.displayName ?? "Super Admin",
          role: "Super Admin",
          associatedCompanyId: companyId,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
      }
    } catch (e) {
      print('Error creating company: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

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
                              // Close the dialog first
                              Navigator.of(context).pop();

                              if (currentUser != null) {
                                // Call the function to create a company
                                await _createCompany(
                                    context, currentUser.uid, companyName);

                                // Navigate to the AdminHomeScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminHomeScreen(),
                                  ),
                                );
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
          // Join a Company Button (Optional)
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
                          decoration: const InputDecoration(
                              hintText: "Enter Company UID"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              // Close the dialog first
                              Navigator.of(context).pop();

                              // Navigate to the AdminHomeScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminHomeScreen(),
                                ),
                              );
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
