import 'dart:math';

import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';

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
}
