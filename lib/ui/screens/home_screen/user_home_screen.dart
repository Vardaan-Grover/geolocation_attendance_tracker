import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart'; // Import your company model
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/title_button.dart';

class UserHomeScreen extends StatefulWidget {
  final User user;

  const UserHomeScreen(this.user, {super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String hours = '6hr 43min';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "GeoLocation Attendance Tracker",
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            FutureBuilder<Company?>(
              future: FirestoreFunctions.fetchCompany(
                  widget.user.associatedCompanyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); 
                } else if (snapshot.hasError) {
                  return const Text(
                      'Error fetching company name');
                } else if (snapshot.hasData) {
                  final company = snapshot.data;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Company Name'),
                      Text(company?.name ?? 'Unknown'), // Show the company name
                    ],
                  );
                } else {
                  return const Text(
                      'No company data available'); // Handle no data case
                }
              },
            ),
            const SizedBox(height: largeSpacing),
            const Center(
              child: Text(
                "Selected Branch Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Working Time Record For Today',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  hours,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: largeSpacing),
            TitleButton(
              title: 'Update Branch',
              icon: Icons.update,
              onPressed: () {},
            ),
            const SizedBox(height: mediumSpacing),
            TitleButton(
              title: 'See My Report',
              icon: Icons.report,
              onPressed: () {},
            ),
            const SizedBox(height: mediumSpacing),
            TitleButton(
              title: 'Manual Log',
              icon: Icons.last_page_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
