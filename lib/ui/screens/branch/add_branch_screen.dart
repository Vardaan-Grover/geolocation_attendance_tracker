import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddBranchScreen extends StatefulWidget {
  final User user;
  final LatLng selectedCoordinates;

  const AddBranchScreen({
    super.key,
    required this.selectedCoordinates,
    required this.user,
  });

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  final _branchAddressController = TextEditingController();
  final _branchRadiusController = TextEditingController();

  @override
  void dispose() {
    _branchNameController.dispose();
    _branchAddressController.dispose();
    _branchRadiusController.dispose();
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
      final branchRadius = _branchRadiusController.text;
      final branchCoordinates = widget.selectedCoordinates;

      // You can now use the collected data to create a branch object or send it to a server
      print('Associated Company ID: ${widget.user.associatedCompanyId}');
      print('Branch Name: $branchName');
      print('Branch Address: $branchAddress');
      print('Branch Radius: $branchRadius');
      print(
          'Branch Coordinates: ${branchCoordinates.latitude}, ${branchCoordinates.longitude}');

      final branch = Branch(
        name: branchName,
        address: branchAddress,
        latitude: branchCoordinates.latitude,
        longitude: branchCoordinates.longitude,
        radius: int.parse(branchRadius),
      );

      final addBranchResult = await FirestoreFunctions.addBranch(
        companyId: widget.user.associatedCompanyId,
        branch: branch,
      );

      if (addBranchResult == 'success') {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add branch. Please try again.'),
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
        title: const Text('Add Branch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(largeSpacing),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: isLoading ? CircularProgressIndicator() : Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
