import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/manual_check_in_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/user_info_header.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/title_button.dart';

class UserHomeScreen extends StatefulWidget {
  final User user;

  const UserHomeScreen(this.user, {super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final authUser = AuthFunctions.getCurrentUser();
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _companyStream;
  List<double>? selectedBranchCoordinates;

  void startCompanyStream() {
    final authUser = AuthFunctions.getCurrentUser();
    if (authUser != null) {
      setState(() {
        _companyStream = FirebaseFirestore.instance
            .collection('companies')
            .doc(widget.user.associatedCompanyId)
            .snapshots();
      });
    }
  }

  void getSelectedBranchCoordinatesForUser() {
    final branchCoordinates = widget.user.selectedBranchCoordinates;
    setState(() {
      selectedBranchCoordinates = branchCoordinates;
    });
  }

  @override
  void initState() {
    super.initState();
    startCompanyStream();
    getSelectedBranchCoordinatesForUser();
  }

  String getBranchFromCoordinates(Company company) {
    if (selectedBranchCoordinates == null ||
        selectedBranchCoordinates!.isEmpty) {
      return 'No branch selected';
    }
    try {
      final Branch selectedBranch = company.branches.firstWhere(
        (branch) =>
            branch.latitude == selectedBranchCoordinates![0] &&
            branch.longitude == selectedBranchCoordinates![1],
      );
      return selectedBranch.name;
    } catch (e) {
      print(e);
    }
    return 'Branch not found';
  }

  // Method to show bottom sheet for selecting branch
  void _showBranchSelectionSheet(Company company) {
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
              if (company.branches.isNotEmpty)
                ...company.branches.map((branch) {
                  return ListTile(
                    title: Text(branch.name),
                    onTap: () async {
                      final authUser = AuthFunctions.getCurrentUser();
                      FirestoreFunctions.updateSelectedBranchCoordinates(
                        uid: authUser!.uid,
                        branch: branch,
                      );
                      setState(() {
                        selectedBranchCoordinates = [
                          branch.latitude,
                          branch.longitude
                        ];
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  );
                })
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
      body: _companyStream == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: _companyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: const Text('Something went wrong'));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final snapshotData = snapshot.data;
                if (snapshotData != null) {
                  final companyData = snapshotData.data();
                  if (companyData != null && companyData.isNotEmpty) {
                    final company = Company.fromFirestore(companyData);
                    return Padding(
                      padding: const EdgeInsets.all(largeSpacing),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserInfoHeader(company: company, user: widget.user),
                          const SizedBox(height: largeSpacing),
                          const Text(
                            "Selected Branch Name",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: mediumSpacing),
                          Text(
                            getBranchFromCoordinates(company),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: largeSpacing),
                          Column(
                            children: [
                              const Text('Working Time Record For Today',
                                  style: TextStyle(fontSize: 20)),
                              Text('6hr 43min',
                                  style: const TextStyle(fontSize: 20)),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: largeSpacing),
                          TitleButton(
                            icon: Icons.update,
                            title: 'Change Branch',
                            onPressed: () => _showBranchSelectionSheet(company),
                          ),
                          const SizedBox(height: largeSpacing),
                          TitleButton(
                            icon: Icons.person,
                            title: 'Manual Check-In',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManualCheckInScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                }
                return Center(child: const Text('Company not found'));
              },
            ),
    );
  }
}
