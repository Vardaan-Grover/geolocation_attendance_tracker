import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/manual_check_in_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/title_button.dart';

class UserHomeScreen extends StatefulWidget {
  final User user;

  const UserHomeScreen(this.user, {Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  String hours = '6hr 43min';
  String? selectedBranch;
  List<Branch> branches = [];
  bool isLoadingBranches = true;
  bool branchSelected = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Load branches when the widget is initialized
    _loadBranches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadBranches() async {
    print(
        "Loading branches for company ID: ${widget.user.associatedCompanyId}");
    final fetchedBranches =
        await FirestoreFunctions.fetchBranches(widget.user.associatedCompanyId);
    print("Fetched branches: $fetchedBranches");

    setState(() {
      branches = fetchedBranches;
      print('Branchessssssssss...............:$branches');

      
      if (widget.user.selectedBranchCoordinates != null) {
       
        final userCoordinates = widget.user.selectedBranchCoordinates!;

        print("User coordinates: $userCoordinates");

       
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

        print("Matching branch: ${matchingBranch.name}");

        
        if (matchingBranch.name != "Unknown") {
          selectedBranch =
              matchingBranch.name; 
          branchSelected = true; 
        } else {
          selectedBranch = null; 
          branchSelected = false; 
        }
      } else {
        
        selectedBranch = null;
        branchSelected = false;
      }

      isLoadingBranches = false; 
      print(
          "Loading branches completed. Branch selected: $branchSelected, Selected branch: $selectedBranch");
    });
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
                  print("Company name fetched: ${company?.name}");
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

            // Branch Dropdown Menu
            if (isLoadingBranches)
              const CircularProgressIndicator()
            else if (branches.isEmpty)
              const Text("No branches available")
            else
              FadeTransition(
                opacity: _animation,
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: branchSelected
                        ? selectedBranch
                        : null, // Allow null if not selected
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
                              selectedBranch =
                                  newValue; // Update selected branch
                              branchSelected =
                                  true; // Disable the dropdown after selection
                            });
                          },
                  ),
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

            // Update Branch Button - Opens Bottom Sheet
            TitleButton(
              icon: Icons.update,
              title: 'Change Branch',
              onPressed: _showBranchSelectionSheet,
            ),
            const SizedBox(height: largeSpacing),

            // Manual Check-In Button
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
