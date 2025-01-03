import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/in_out_duration_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/auth_functions.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/services/location_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/manual_check_in_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/user_info_header.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/title_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeScreen extends StatefulWidget {
  final User user;

  const UserHomeScreen(this.user, {super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  static const IS_LOCATION_TRACKING_ACTIVE = "isLocationTrackingActive";
  final authUser = AuthFunctions.getCurrentUser();
  bool? isLocationTrackingActive;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _companyStream;
  List<double>? selectedBranchCoordinates;

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

  void getInitialIsLocationTrackingActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final fetchedValue = prefs.getBool(IS_LOCATION_TRACKING_ACTIVE);
    setState(() {
      isLocationTrackingActive = fetchedValue;
    });
  }

  void getSelectedBranchCoordinatesForUser() {
    final branchCoordinates = widget.user.selectedBranchCoordinates;
    setState(() {
      selectedBranchCoordinates = branchCoordinates;
    });
  }

  static const platform = MethodChannel('com.example.location_service');

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      return true;
    }

    return false;
  }

  Future<bool> requestLocationPermission() async {
    // Request location permission
    await Permission.locationWhenInUse.request();
    var status = await Permission.locationAlways.request();

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

  Future<void> startLocationService() async {
    try {
      await platform.invokeMethod(
        'startLocationUpdates',
        {"uid": authUser!.uid},
      );
    } on PlatformException catch (e) {
      print("Error: $e");
    }
  }

  Future<void> stopLocationService() async {
    try {
      await platform.invokeMethod('stopLocationUpdates');
    } on PlatformException catch (e) {
      print("Failed to stop location service: ${e.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    startCompanyStream();
    getSelectedBranchCoordinatesForUser();
    getInitialIsLocationTrackingActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "GeoLocation Attendance Tracker",
            style: TextStyle(fontSize: 25),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserInfoHeader(company: company, user: widget.user),
                          const SizedBox(height: mediumSpacing),
                          const Divider(),
                          const SizedBox(height: largeSpacing),
                          const Text(
                            "Location Tracking",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: mediumSpacing),
                          Transform.scale(
                            scale: 1.5,
                            child: Switch(
                              value: isLocationTrackingActive ?? false,
                              activeColor: Colors.green,
                              onChanged: (bool value) =>
                                  setIsLocationTrackingActive(value),
                            ),
                          ),
                          const SizedBox(height: largeSpacing),
                          const Divider(),
                          const SizedBox(height: largeSpacing),
                          const Text(
                            "Selected Branch Name",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: mediumSpacing),
                          Text(
                            getBranchFromCoordinates(company),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: largeSpacing),
                          const Divider(),
                          const SizedBox(height: largeSpacing),
                          Column(
                            children: [
                              const Text('Working Time Record For Today',
                                  style: TextStyle(fontSize: 20)),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(authUser!.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error fetching attendance: ${snapshot.error}'));
                                    }
                                    final data = snapshot.data?.data();
                                    if (data != null) {
                                      final tracking = (data['tracking']
                                              as Map<String, dynamic>)
                                          .map(
                                        (key, value) => MapEntry(
                                          key,
                                          (value as List<dynamic>)
                                              .map((x) =>
                                                  InOutDuration.fromFirestore(
                                                      x))
                                              .toList(),
                                        ),
                                      );
                                      final today = DateTime.now()
                                          .toIso8601String()
                                          .substring(0, 10);
                                      double activeTimeToday = 0;
                                      if (tracking.containsKey(today)) {
                                        final todayTracking = tracking[today];
                                        for (final tracking in todayTracking!) {
                                          print(tracking.durationInMinutes);
                                          activeTimeToday +=
                                              tracking.durationInMinutes ?? 0;
                                        }
                                      }
                                      return Text(
                                        "${(activeTimeToday / 60).toInt()}hr ${(activeTimeToday % 60).toInt()}min",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                    return Text('Loading...');
                                  })
                            ],
                          ),
                          const SizedBox(height: largeSpacing),
                          const Divider(),
                          const SizedBox(height: largeSpacing),
                          TitleButton(
                            icon: Icons.update,
                            title: 'Change Branch',
                            onPressed: () => _showBranchSelectionSheet(company),
                          ),
                          const SizedBox(height: largeSpacing),
                          TitleButton(
                            icon: Icons.person,
                            title: 'Manual Check-In',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ManualCheckInScreen(company),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                }
                return Center(child: const Text('Company not found'));
              },
            ),
    );
  }

  void setIsLocationTrackingActive(bool value) async {
    if (value) {
      final isNotificationGranted = await requestNotificationPermission();
      final isLocationGranted = await requestLocationPermission();
      if (isNotificationGranted && isLocationGranted) {
        startLocationService();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLocationTrackingActive', value);
        setState(() {
          isLocationTrackingActive = value;
        });
      }
    } else {
      stopLocationService();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLocationTrackingActive', value);
      setState(() {
        isLocationTrackingActive = value;
      });
    }
  }

  // Method to show bottom sheet for selecting branch
  void _showBranchSelectionSheet(Company company) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a Branch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (company.branches.isNotEmpty)
                ...company.branches.map((branch) {
                  return ListTile(
                    title: Text(branch.name),
                    onTap: () async {
                      final authUser = AuthFunctions.getCurrentUser();
                      FirestoreFunctions.updateSelectedBranchCoordinates(
                        uid: authUser!.uid,
                        branch: branch,
                      );
                      setState(() {
                        selectedBranchCoordinates = [
                          branch.latitude,
                          branch.longitude
                        ];
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  );
                })
              else
                const Center(child: Text("No branches available")),
            ],
          ),
        );
      },
    );
  }

  String getBranchFromCoordinates(Company company) {
    if (selectedBranchCoordinates == null ||
        selectedBranchCoordinates!.isEmpty) {
      return 'No branch selected';
    }
    try {
      final Branch selectedBranch = company.branches.firstWhere(
        (branch) =>
            branch.latitude == selectedBranchCoordinates![0] &&
            branch.longitude == selectedBranchCoordinates![1],
      );
      return selectedBranch.name;
    } catch (e) {
      print(e);
    }
    return 'Branch not found';
  }
}
