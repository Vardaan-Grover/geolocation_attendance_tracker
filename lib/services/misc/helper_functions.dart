import 'dart:math';

import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HelperFunctions {
  /// Generates a 5 digit code that may or may not be unique within the Firestore Database.
  static String generateCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    String generatedCode = List.generate(
      5,
      (index) => characters[random.nextInt(characters.length)],
    ).join();

    return generatedCode;
}

  /// Uses `generateCode()` function in conjunction with `FirestoreFunctions` class's function to finally generate a code that IS unique within the Firestore Database.
  static Future<String> generateUniqueCode() async {
    String generatedCode = generateCode();
    bool isUnique = false;

    while (!isUnique) {
      if (await FirestoreFunctions.isCodeUnique(generatedCode)) {
        isUnique = true;
      } else {
        generatedCode = generateCode();
      }
    }

    return generatedCode;
  }

  static double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  static int haversineFormula(LocationData pt1, LocationData pt2) {
    const int R = 6371; // Radius of the earth in km
    final double lat1 = pt1.latitude!;
    final double lon1 = pt1.longitude!;
    final double lat2 = pt2.latitude!;
    final double lon2 = pt2.longitude!;
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final int d = (R * c).toInt(); // Distance in m

    return d;
  }
}
