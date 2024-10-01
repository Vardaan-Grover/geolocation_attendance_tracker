import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class ManualCheckInScreen extends StatefulWidget {
  const ManualCheckInScreen({super.key});

  @override
  State<ManualCheckInScreen> createState() => _ManualCheckInScreenState();
}

class _ManualCheckInScreenState extends State<ManualCheckInScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  Set<Polygon> _polygons = {};
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;

    if (permission.isDenied) {
      await Permission.locationWhenInUse.request();
    }

    if (await Permission.locationWhenInUse.isGranted) {
      if (await Permission.locationAlways.isDenied) {
        await Permission.locationAlways.request();
      }

      _getCurrentLocation();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
    _moveCamera(_currentLocation!);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _applyCustomMapStyle();
  }

  void _moveCamera(LatLng location) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
  }

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  void _applyCustomMapStyle() async {
    String style = '''
    [
      {
        "featureType": "all",
        "elementType": "geometry",
        "stylers": [
          { "color": "#e0e0e0" }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    ]
    ''';
    // ignore: deprecated_member_use
    _mapController.setMapStyle(style);
  }

  void _onSwipeIn() {
    setState(() {
      checkInTime = DateTime.now();
      isCheckedIn = true;
    });
    if (_currentLocation != null) {
      _moveCamera(_currentLocation!);
    }
  }

  void _onSwipeOut() {
    setState(() {
      checkOutTime = DateTime.now();
      isCheckedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Check-In/Check-Out')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _currentLocation == null
                      ? const Center(child: Text('Location not found'))
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation!,
                            zoom: 15,
                          ),
                          polygons: _polygons,
                          onMapCreated: _onMapCreated,
                        ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: _zoomIn,
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: _zoomOut,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SwipeActionCell(
                  key: ValueKey(0),
                  leadingActions: [
                    SwipeAction(
                      title: 'Check-In',
                      onTap: (CompletionHandler handler) async {
                        _onSwipeIn();
                      },
                      color: Colors.green,
                    ),
                  ],
                  trailingActions: [
                    SwipeAction(
                      title: 'Check-Out',
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
                    child: Text(
                      'Time Spent: ${checkOutTime!.difference(checkInTime!).inMinutes} minutes',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
    );
  }
}
