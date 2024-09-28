import 'package:location/location.dart';

class LocationFunctions {
  static final Location location = Location();

  /// Requests the user to grant location access.
  /// 
  /// Returns: A string message telling exactly what happened.
  static Future<String> requestLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    // LocationData _locationData;

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return 'Service still not enabled after requesting.';
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return 'Location permission still not granted after requesting.';
      }
    }

    return 'Location service and permission granted.';
  }

  /// Enables background location tracking.
  /// 
  /// Returns:
  /// - `true`: If tracking is enabled successfully.
  /// - `false`: If tracking is not enabled successfully.
  static Future<bool> enableBackgroundLocation() async {
    return await location.enableBackgroundMode(enable: true);
  }


  /// Changes location tracking settings by modifying factors including intervals between location detection and accuracy of location.
  /// 
  /// Returns:
  /// - `true`: If settings changed successfully.
  /// - `false`: If setting could not be changed successfully.
  static Future<bool> changeLocationSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 300000,
  }) async {
    return await location.changeSettings(
      accuracy: accuracy,
      interval: interval,
    );
  }
}
