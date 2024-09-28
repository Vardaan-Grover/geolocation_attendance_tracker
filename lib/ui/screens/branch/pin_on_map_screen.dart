import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/location_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/add_branch_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PinOnMapScreen extends StatefulWidget {
  final User user;

  const PinOnMapScreen(this.user, {super.key});

  @override
  State<PinOnMapScreen> createState() => _PinOnMapScreenState();
}

class _PinOnMapScreenState extends State<PinOnMapScreen> {
  bool isLoading = false;

  final Location location = Location();
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  // LatLng? _selectedLocation;

  Future<void> onGetMyLocation() async {
    setState(() {
      isLoading = true;
    });
    final permission = await location.hasPermission();
    if (permission == PermissionStatus.granted) {
      final userLocation = await LocationFunctions.getUserLocation();
      if (userLocation != null) {
        final userLatLng =
            LatLng(userLocation.latitude!, userLocation.longitude!);
        await _controller!
            .animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 18));
        _onTap(userLatLng);
      }
    } else {
      await LocationFunctions.requestLocation();
    }
    setState(() {
      isLoading = false;
    });
  }

  void onProceed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddBranchScreen(
          user: widget.user,
          selectedCoordinates: _markers.first.position,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
          ),
        ),
      );
      // _selectedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Branch Location'),
      ),
      floatingActionButton: SizedBox(
        width: 148,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              key: const Key('get_my_location'),
              onPressed: onGetMyLocation,
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text('Get my location'),
            ),
            SizedBox(height: smallSpacing),
            if (_markers.isNotEmpty)
              FilledButton(
                key: const Key('proceed'),
                onPressed: onProceed,
                child: Text('Proceed'),
              ),
          ],
        ),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 4,
        ),
        markers: _markers,
        onTap: _onTap,
        zoomGesturesEnabled: true,
        compassEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
