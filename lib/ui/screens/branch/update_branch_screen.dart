import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/home/admin_home_screen.dart';

class UpdateBranchScreen extends StatefulWidget {
  final Branch branch; // Pass the branch to update
  final User user; // User associated with the branch

  const UpdateBranchScreen({
    super.key,
    required this.branch,
    required this.user,
  });

  @override
  State<UpdateBranchScreen> createState() => _UpdateBranchScreenState();
}

class _UpdateBranchScreenState extends State<UpdateBranchScreen> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  final _branchAddressController = TextEditingController();
  final _branchRadiusController = TextEditingController();
  final _branchLatitudeController = TextEditingController();
  final _branchLongitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current branch details
    _branchNameController.text = widget.branch.name;
    _branchAddressController.text = widget.branch.address;
    _branchRadiusController.text = widget.branch.radius.toString();
    _branchLatitudeController.text = widget.branch.latitude.toString();
    _branchLongitudeController.text = widget.branch.longitude.toString();
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _branchAddressController.dispose();
    _branchRadiusController.dispose();
    _branchLatitudeController.dispose();
    _branchLongitudeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Save the form data
      final branchName = _branchNameController.text;
      final branchAddress = _branchAddressController.text;
      final branchRadius = int.parse(_branchRadiusController.text);
      final branchLatitude = double.parse(_branchLatitudeController.text);
      final branchLongitude = double.parse(_branchLongitudeController.text);

      final updatedBranch = Branch(
        name: branchName,
        address: branchAddress,
        latitude: branchLatitude,
        longitude: branchLongitude,
        radius: branchRadius,
      );

      final updateBranchResult = await FirestoreFunctions.updateBranch(
        companyId: widget.user.associatedCompanyId, // Pass the company ID to the function
        oldBranch: widget.branch, // Pass the old branch details
        newBranch: updatedBranch, // Pass the updated branch details
      );

      if (updateBranchResult == 'success') {
        // Show snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Branch updated successfully!'),
          ),
        );

        // Navigate to AdminHomeScreen after a short delay
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomeScreen(widget.user)), // Navigate to AdminHomeScreen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update branch. Please try again.'),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Branch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Replace with your constant
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _branchNameController,
                decoration: const InputDecoration(labelText: 'Branch Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the branch name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _branchAddressController,
                decoration: const InputDecoration(labelText: 'Branch Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the branch address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _branchRadiusController,
                decoration: const InputDecoration(
                    labelText: 'Branch Detection Radius (in meters)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the branch detection radius';
                  } else if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  } else if (int.tryParse(value)! < 25) {
                    return 'Branch detection radius should be at least 25 meters';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _branchLatitudeController,
                decoration: const InputDecoration(labelText: 'Branch Latitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the branch latitude';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _branchLongitudeController,
                decoration: const InputDecoration(labelText: 'Branch Longitude'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the branch longitude';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
