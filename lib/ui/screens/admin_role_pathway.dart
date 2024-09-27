import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home_screen.dart/admin_home_screen.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {
                              // First close the dialog
                              Navigator.of(context).pop();

                              // Navigate to the AdminHomeScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminHomeScreen(),
                                ),
                              );

                              print("Company Name: $companyName");
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
                            onPressed: () {
                              // First close the dialog
                              Navigator.of(context).pop();

                              // Navigate to the AdminHomeScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminHomeScreen(),
                                ),
                              );

                              print("Company UID: $companyUID");
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
