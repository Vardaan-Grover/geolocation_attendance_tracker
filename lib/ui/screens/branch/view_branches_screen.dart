import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';

class ViewBranchesScreen extends StatefulWidget {
  final Company company;

  const ViewBranchesScreen(this.company, {super.key});

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
                // Navigate to edit branch screen
              },
            ),
          );
        },
      ),
    );
  }
}
