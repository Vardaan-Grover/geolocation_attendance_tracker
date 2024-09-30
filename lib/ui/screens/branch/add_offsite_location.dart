import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddOffsiteLocation extends StatefulWidget {
  final User user;
  final LatLng selectedCoordinates;

  const AddOffsiteLocation({
    super.key,
    required this.selectedCoordinates,
    required this.user,
  });

  @override
  State<AddOffsiteLocation> createState() => _AddOffsiteLocationState();
}

class _AddOffsiteLocationState extends State<AddOffsiteLocation> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();

  @override
  void dispose() {
    _locationNameController.dispose();
    _locationAddressController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Get the form data
      final locationName = _locationNameController.text;
      final locationAddress = _locationAddressController.text;
      final locationCoordinates = widget.selectedCoordinates;

      // Debugging output
      print('Super Admin ID: ${widget.user.id}');
      print('Offsite Location Name: $locationName');
      print('Offsite Location Address: $locationAddress');
      print('Coordinates: ${locationCoordinates.latitude}, ${locationCoordinates.longitude}');

      // Save the offsite location using FirestoreFunctions
      final result = await FirestoreFunctions.addOffsiteLocation(
        userId: widget.user.id, // Super Admin ID
        locationData: {
          'name': locationName,
          'address': locationAddress,
          'latitude': locationCoordinates.latitude,
          'longitude': locationCoordinates.longitude,
        },
      );

      if (result == 'success') {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add offsite location. Please try again.'),
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
        title: const Text('Add Offsite Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationAddressController,
                decoration: const InputDecoration(labelText: 'Location Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
