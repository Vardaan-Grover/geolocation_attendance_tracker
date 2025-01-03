import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class TestingBackgroundGpsScreen extends StatefulWidget {
  const TestingBackgroundGpsScreen({super.key});

  @override
  State<TestingBackgroundGpsScreen> createState() => _TestingBackgroundGpsScreenState();
}

class _TestingBackgroundGpsScreenState extends State<TestingBackgroundGpsScreen> {
  @override
  void initState() {
    super.initState();
  }

  static const platform = MethodChannel('com.example.location_service');

  Future<void> requestLocationPermission() async {
    var status = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse
    ].request();

    if ((status[Permission.location]?.isGranted ?? false) &&
        (status[Permission.locationAlways]?.isGranted ?? false) &&
        (status[Permission.locationWhenInUse]?.isGranted ?? false)) {
      startLocationService();
    } else if ((status[Permission.location]?.isDenied ?? false) ||
        (status[Permission.locationAlways]?.isDenied ?? false) ||
        (status[Permission.locationWhenInUse]?.isDenied ?? false)) {
      print('Location permission denied');
    } else if ((status[Permission.location]?.isPermanentlyDenied ?? false) ||
        (status[Permission.locationAlways]?.isPermanentlyDenied ?? false) ||
        (status[Permission.locationWhenInUse]?.isPermanentlyDenied ?? false)) {
      openAppSettings();
    }
  }

  Future<void> startLocationService() async {
    try {
      await platform.invokeMethod('startLocationUpdates');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: requestLocationPermission,
              child: const Text(
                'Start Location Service',
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: stopLocationService,
              child: const Text(
                'Stop Location Service',
              ),
            ),
          ],
        ),
      ),
    );
  }
}