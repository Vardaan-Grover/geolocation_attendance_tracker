import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/in_out_duration_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/services/location_functions.dart';
import 'package:geolocation_attendance_tracker/services/misc/helper_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualCheckInScreen extends StatefulWidget {
  // final User user;
  final Company company;

  const ManualCheckInScreen(this.company, {super.key});

  @override
  State<ManualCheckInScreen> createState() => _ManualCheckInScreenState();
}

class _ManualCheckInScreenState extends State<ManualCheckInScreen> {
  LocationData? userCoordinates;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckedIn = false;
  bool isLoading = false;
  final authUser = AuthFunctions.getCurrentUser();
  final TextEditingController offsiteNameController = TextEditingController();
  final TextEditingController offsiteAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    setInitStatus();
  }

  Future<bool> requestLocationPermission() async {
    // Request location permission
    var status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      // Permission granted
      return true;
    } else if (status.isDenied) {
      // Permission denied
      return false;
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
      return false;
    }

    return false;
  }

  void setInitStatus() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.getString('inTime') != null) {
      setState(() {
        checkInTime = DateTime.parse(sharedPrefs.getString('inTime')!);
        isCheckedIn = true;
      });
    }

    if (sharedPrefs.getString('outTime') != null) {
      setState(() {
        checkOutTime = DateTime.parse(sharedPrefs.getString('outTime')!);
        isCheckedIn = false;
      });
    }
  }

  void _onSwipeIn() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString('inTime', DateTime.now().toIso8601String());
    sharedPrefs.remove('outTime');
    setState(() {
      checkInTime = DateTime.now();
      isCheckedIn = true;
    });
  }

  void _onSwipeOut() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.getString('inTime') != null) {
      sharedPrefs.setString('outTime', DateTime.now().toIso8601String());
    }
    setState(() {
      checkOutTime = DateTime.now();
      isCheckedIn = false;
    });
  }

  Future<void> onSubmit() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final inTime = sharedPrefs.getString('inTime');
    final outTime = sharedPrefs.getString('outTime');

    print('In Time: $inTime');
    print('Out Time: $outTime');
    print('Offsite Name: ${offsiteNameController.text}');
    print('Offsite Address: ${offsiteAddressController.text}');
    print('Date: ${DateTime.now().toIso8601String().substring(0, 10)}');

    if (offsiteAddressController.text.isNotEmpty &&
        offsiteNameController.text.isNotEmpty &&
        inTime != null &&
        outTime != null) {
      await FirestoreFunctions.updateTracking(
        uid: authUser!.uid,
        date: DateTime.now().toIso8601String().substring(0, 10),
        obj: InOutDuration(
            inTime: Timestamp.fromDate(DateTime.parse(inTime)),
            placeName: offsiteNameController.text,
            placeAddress: offsiteAddressController.text),
      );
      sharedPrefs.remove('inTime');
      sharedPrefs.remove('outTime');
      setState(() {
        checkInTime = null;
        checkOutTime = null;
        isCheckedIn = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Check-In/Check-Out')),
      body: widget.company == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: widget.company.offsites.length != 0
                        ? ListView.builder(
                            itemBuilder: (context, index) {
                              return ListTile(
                                title:
                                    Text(widget.company.offsites[index].name),
                                subtitle: Text(
                                    widget.company.offsites[index].address),
                                trailing: userCoordinates != null
                                    ? Text(
                                        '${HelperFunctions.haversineFormula(
                                          userCoordinates!,
                                          LocationData.fromMap({
                                            'latitude': widget.company
                                                .offsites[index].latitude,
                                            'longitude': widget.company
                                                .offsites[index].longitude,
                                          }),
                                        )}km away',
                                      )
                                    : null,
                                onTap: () {
                                  offsiteNameController.text =
                                      widget.company.offsites[index].name;
                                  offsiteAddressController.text =
                                      widget.company.offsites[index].address;
                                },
                              );
                            },
                            itemCount: widget.company.offsites.length,
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          )),
                TextFormField(
                  controller: offsiteNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Offsite Name',
                  ),
                ),
                TextFormField(
                  controller: offsiteAddressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Offsite Address',
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    final isGranted = await requestLocationPermission();
                    if (isGranted) {
                      final userLocation =
                          await LocationFunctions.getUserLocation();
                      setState(() {
                        userCoordinates = userLocation;
                      });
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Text('Calculate Distance From Me'),
                ),
                SwipeActionCell(
                  key: ValueKey(0),
                  leadingActions: [
                    SwipeAction(
                      title: 'In',
                      onTap: (CompletionHandler handler) async {
                        _onSwipeIn();
                      },
                      color: Colors.green,
                    ),
                  ],
                  trailingActions: [
                    SwipeAction(
                      title: 'Out',
                      onTap: (CompletionHandler handler) async {
                        _onSwipeOut();
                      },
                      color: Colors.red,
                    ),
                  ],
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isCheckedIn
                          ? 'Checked In at ${checkInTime?.toLocal().toString()}'
                          : checkOutTime != null
                              ? 'Checked Out at ${checkOutTime?.toLocal().toString()}'
                              : 'Swipe to Check-In/Check-Out',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (checkInTime != null && checkOutTime != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Spent: ${checkOutTime!.difference(checkInTime!).inMinutes} minutes',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        FilledButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await onSubmit();
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: isLoading
                              ? CircularProgressIndicator()
                              : Text("Submit"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
