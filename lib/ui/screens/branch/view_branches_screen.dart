import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart'; // Assuming deleteBranch is in this file
import 'package:geolocation_attendance_tracker/ui/screens/branch/update_branch_screen.dart';

class ViewBranchesScreen extends StatefulWidget {
  final Company company;
  final User user;

  const ViewBranchesScreen({super.key, required this.company, required this.user});
 
  @override
  State<ViewBranchesScreen> createState() => _ViewBranchesScreenState();
}

class _ViewBranchesScreenState extends State<ViewBranchesScreen> {
  // Function to delete a branch and show a confirmation dialog
  void _deleteBranchConfirmation(BuildContext context, Branch branch) async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: const Text('Are you sure you want to delete this branch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      // Call the deleteBranch function from FirestoreFunctions
      final result = await FirestoreFunctions.deleteBranch(
        companyId: widget.user.associatedCompanyId, // Assuming company.id exists
        branch: branch,
      );

      if (result == 'success') {
        setState(() {
          widget.company.branches.remove(branch); // Remove branch from local state
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branch deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

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
              icon: const Icon(Icons.delete_rounded),
              onPressed: () {
                _deleteBranchConfirmation(context, branch); // Trigger the delete process
              },
            ),
            onTap: () {
              // Navigate to UpdateBranchScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UpdateBranchScreen(
                    branch: branch,
                    user: widget.user,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
