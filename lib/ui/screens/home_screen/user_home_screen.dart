import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/manual_check_in_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/title_button.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

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
    print("Initializing UserHomeScreen");
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      print(
          "Fetching branches for company ID: ${widget.user.associatedCompanyId}");

      // Fetch branches from Firestore
      final fetchedBranches = await FirestoreFunctions.fetchBranches(
          widget.user.associatedCompanyId);
      print("Fetched branches: $fetchedBranches");

      // Fetch saved branch from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedBranch =
          prefs.getString('selectedBranch'); // Retrieve the saved branch
      print("Saved branch in SharedPreferences: $savedBranch");

      setState(() {
        branches = fetchedBranches;

        if (savedBranch != null) {
          // If saved branch exists, select it automatically
          selectedBranch = savedBranch;
          branchSelected = true;
          print(
              "Selected branch loaded from SharedPreferences: $selectedBranch");
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
            print(
                "Matching branch found based on user coordinates: $selectedBranch");
          } else {
            selectedBranch = null;
            branchSelected = false;
            print("No matching branch found based on user coordinates.");
          }
        } else {
          selectedBranch = null;
          branchSelected = false;
          print("No branch coordinates available for user.");
        }

        isLoadingBranches = false;
        print("Branch loading completed.");
      });
    } catch (e) {
      setState(() {
        isLoadingBranches = false;
      });
      print("Error fetching branches: $e");
    }
  }

  Future<void> _saveSelectedBranch(String branchName) async {
    // Save the selected branch to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBranch', branchName);
    print("Saved selected branch: $branchName to SharedPreferences");
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
                        branchSelected =
                            true; // Lock the dropdown after selection
                      });
                      _saveSelectedBranch(
                          branch.name); // Save the selected branch
                      Navigator.pop(context); // Close the bottom sheet
                      print(
                          "Selected branch from bottom sheet: $selectedBranch");
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
            else if (branches.isEmpty)
              const Text("No branches available")
            else
              SizedBox(
                width: double.infinity,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: branchSelected ? selectedBranch : null,
                  hint: const Text("Select Branch Name"),
                  items: branches.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch.name,
                      child: Text(branch.name),
                    );
                  }).toList(),
                  onChanged: branchSelected
                      ? null // Disable if branch is selected
                      : (newValue) {
                          setState(() {
                            selectedBranch = newValue;
                            branchSelected =
                                true; // Disable the dropdown after selection
                          });
                          _saveSelectedBranch(
                              newValue!); // Save selected branch
                          print(
                              "Branch selected via dropdown: $selectedBranch");
                        },
                ),
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
