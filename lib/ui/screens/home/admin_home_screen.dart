import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/add_offsite_location.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/view_branches_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/employee_list_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/add_branch_pathway_modal_sheet.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/title_button.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/user_info_header.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminHomeScreen extends StatefulWidget {
  final User user;

  const AdminHomeScreen(this.user, {super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _companyStream;
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

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

  void onAddStaff() async {
    final company =
        await FirestoreFunctions.fetchCompany(widget.user.associatedCompanyId);
    final codes = {
      'Employee': company!.employeeCode,
      if (widget.user.role == "super-admin") 'Admin': company.adminCode,
    };
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text('Invite Codes'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: largeSpacing),
              ...codes.entries.map(
                (entry) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entry.key} Code',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Row(
                      children: [
                        Text(
                          entry.value,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          iconSize: 14,
                          onPressed: () => Clipboard.setData(
                            ClipboardData(text: entry.value),
                          ),
                          icon: Icon(Icons.copy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startCompanyStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Gelocation Attendance Tracker'),
        ),
        floatingActionButton: SizedBox(
          width: 120,
          height: 48,
          child: FloatingActionButton(
            onPressed: onAddStaff,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.add), Text('Add Staff')],
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
                          children: [
                            UserInfoHeader(
                              user: widget.user,
                              company: company,
                            ),
                            const SizedBox(height: mediumSpacing),
                            const Divider(),
                            const SizedBox(height: mediumSpacing),
                            TitleButton(
                              title: 'View Branches',
                              icon: Icons.business,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ViewBranchesScreen(
                                    company: company,
                                    user: widget.user,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: mediumSpacing),
                            TitleButton(
                              title: 'Add a branch / office',
                              icon: Icons.add_business,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      AddBranchOffsitePathwayModalSheet(
                                    user: widget.user,
                                    whereTo: "branch",
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: mediumSpacing),
                            TitleButton(
                              title: 'Add an Offsite',
                              icon: Icons.add_home_work_outlined  ,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      AddBranchOffsitePathwayModalSheet(
                                    user: widget.user,
                                    whereTo: "offsite",
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: mediumSpacing),
                            TitleButton(
                              title: 'Employee List/Report',
                              icon: Icons.list_alt,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EmployeesScreen(widget.user)),
                              ),
                            ),
                            const SizedBox(height: mediumSpacing),
                          ],
                        ),
                      );
                    }
                  }
                  return Center(child: const Text('Company not found'));
                }));
  }
}
