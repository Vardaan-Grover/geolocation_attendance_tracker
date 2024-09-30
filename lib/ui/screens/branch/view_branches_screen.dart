import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/update_branch_screen.dart';

class ViewBranchesScreen extends StatefulWidget {
  final Company company;
  final User user;

  const ViewBranchesScreen({super.key, required this.company, required this.user});

  @override
  State<ViewBranchesScreen> createState() => _ViewBranchesScreenState();
}

class _ViewBranchesScreenState extends State<ViewBranchesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.company.name} Branches'),
      ),
      body: ListView.builder(
        itemCount: widget.company.branches.length,
        itemBuilder: (context, index) {
          final branch = widget.company.branches[index];
          return ListTile(
            title: Text(branch.name),
            subtitle: Text(branch.address),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to UpdateBranchScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UpdateBranchScreen(
                      branch: branch,
                      user: widget.user, // Pass the company ID here
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
