import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';

import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/add_branch_pathway_modal_sheet.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/title_button.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/user_info_header.dart';

class AdminHomeScreen extends StatefulWidget {
  final User user;

  const AdminHomeScreen(this.user, {super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Company? company;

  void onAddStaff() {
    final codes = {
      'Employee': company!.employeeCode,
      if (widget.user.role == "super-admin") 'Admin': company!.adminCode,
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

  void getCompany() async {
    final fetchedCompany =
        await FirestoreFunctions.fetchCompany(widget.user.associatedCompanyId);

    if (fetchedCompany != null) {
      setState(() {
        company = fetchedCompany;
      });
    } else {
      print('Company not found');
    }
  }

  @override
  void initState() {
    super.initState();
    getCompany();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserInfoHeader(
              user: widget.user,
              company: company!,
            ),
            const SizedBox(height: mediumSpacing),
            const Divider(),
            const SizedBox(height: mediumSpacing),
            TitleButton(
              title: 'View Branches',
              icon: Icons.business,
              onPressed: () {},
            ),
            const SizedBox(height: mediumSpacing),
            TitleButton(
              title: 'Add a branch / office',
              icon: Icons.add_business,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => AddBranchPathwayModalSheet(),
                );
              },
            ),
            const SizedBox(height: mediumSpacing),
            TitleButton(
              title: 'Attendance Reports',
              icon: Icons.table_chart_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: mediumSpacing),
            TitleButton(
              title: 'Employee List',
              icon: Icons.list_alt,
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
