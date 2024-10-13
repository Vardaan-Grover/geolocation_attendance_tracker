import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/add_branch_screen.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/add_offsite_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BranchRawCoordinatesModalSheet extends StatefulWidget {
  final User user;
  final String whereTo;

  const BranchRawCoordinatesModalSheet({
    super.key,
    required this.user,
    required this.whereTo,
  });

  @override
  State<BranchRawCoordinatesModalSheet> createState() =>
      _BranchRawCoordinatesModalSheetState();
}

class _BranchRawCoordinatesModalSheetState
    extends State<BranchRawCoordinatesModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String? onValidate(String? text) {
    if (text == null || text.isEmpty) {
      return 'Please enter a value.';
    } else if (double.tryParse(text) == null) {
      return 'Please enter a valid number.';
    }
    return null;
  }

  void onProceed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);
      if (widget.whereTo == "branch") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddBranchScreen(
              selectedCoordinates: LatLng(latitude, longitude),
              user: widget.user,
            ),
          ),
        );
      }
      if (widget.whereTo == "offsite") {
        Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddOffsiteLocationScreen(
            selectedCoordinates: LatLng(latitude, longitude),
            user: widget.user,
          ),
        ),
      );
      }
    }
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(largeSpacing),
      padding: EdgeInsets.only(
        top: largeSpacing,
        left: largeSpacing,
        right: largeSpacing,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        minHeight: 150,
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Latitude',
                      ),
                      validator: onValidate,
                    ),
                  ),
                  SizedBox(width: mediumSpacing),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Longitude',
                      ),
                      validator: onValidate,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: mediumSpacing,
            ),
            FilledButton(
              onPressed: onProceed,
              child: Text('Proceed'),
            ),
          ]),
    );
  }
}
