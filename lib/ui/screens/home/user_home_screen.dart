import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/manual_check_in_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/title_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeScreen extends StatefulWidget {
  final User user;

  const UserHomeScreen(this.user, {Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String hours = '6hr 43min';
  String? selectedBranch;
  List<Branch> branches = [];
  bool isLoadingBranches = true;
  bool branchSelected = false;

  @override
  void initState() {
    super.initState();

    // Load branches and check saved branch when widget is initialized
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      // Fetch branches from Firestore
      final fetchedBranches = await FirestoreFunctions.fetchBranches(
          widget.user.associatedCompanyId);

      // Fetch saved branch from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedBranch =
          prefs.getString('selectedBranch'); // Retrieve the saved branch

      setState(() {
        branches = fetchedBranches;

        if (savedBranch != null) {
          // If saved branch exists, select it automatically
          selectedBranch = savedBranch;
          branchSelected = true;
        } else if (widget.user.selectedBranchCoordinates != null) {
          final userCoordinates = widget.user.selectedBranchCoordinates!;

          final matchingBranch = branches.firstWhere(
            (branch) =>
                branch.latitude == userCoordinates[0] &&
                branch.longitude == userCoordinates[1],
            orElse: () => Branch(
                name: "Unknown",
                address: "",
                latitude: 0.0,
                longitude: 0.0,
                radius: 0),
          );

          if (matchingBranch.name != "Unknown") {
            selectedBranch = matchingBranch.name;
            branchSelected = true;
          } else {
            selectedBranch = null;
            branchSelected = false;
          }
        } else {
          selectedBranch = null;
          branchSelected = false;  // Ensures "None" is displayed if no branch is selected
        }

        isLoadingBranches = false;
      });
    } catch (e) {
      setState(() {
        isLoadingBranches = false;
      });
    }
  }

  Future<void> _saveSelectedBranch(String branchName) async {
    // Save the selected branch to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBranch', branchName);
  }

  // Method to show bottom sheet for selecting branch
  void _showBranchSelectionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a Branch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (branches.isNotEmpty)
                ...branches.map((branch) {
                  return ListTile(
                    title: Text(branch.name),
                    onTap: () {
                      setState(() {
                        selectedBranch =
                            branch.name; // Update the selected branch
                        branchSelected = true; // Lock the dropdown after selection
                      });
                      _saveSelectedBranch(
                          branch.name); // Save the selected branch
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  );
                }).toList()
              else
                const Center(child: Text("No branches available")),
            ],
          ),
        );
      },
    );
  }

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
                  return const Text('Error fetching company name');
                } else if (snapshot.hasData) {
                  final company = snapshot.data;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Company Name',
                          style: TextStyle(fontSize: 18)),
                      Text(company?.name ?? 'Unknown',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  );
                } else {
                  return const Text('No company data available');
                }
              },
            ),
            const SizedBox(height: largeSpacing),
            const Text("Selected Branch Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: mediumSpacing),
            if (isLoadingBranches)
              const CircularProgressIndicator()
            else
              Text(
                branchSelected && selectedBranch != null
                    ? selectedBranch!
                    : "None", // Show selected branch or "None" if no branch selected
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: largeSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Working Time Record For Today',
                    style: TextStyle(fontSize: 20)),
                Text(hours, style: const TextStyle(fontSize: 20)),
              ],
            ),
            const Divider(),
            const SizedBox(height: largeSpacing),
            TitleButton(
              icon: Icons.update,
              title: 'Change Branch',
              onPressed: _showBranchSelectionSheet,
            ),
            const SizedBox(height: largeSpacing),
            TitleButton(
              icon: Icons.person,
              title: 'Manual Check-In',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManualCheckInScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
