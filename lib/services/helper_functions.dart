import 'dart:math';

import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';

class HelperFunctions {
  static String generateCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    String generatedCode = List.generate(
      5,
      (index) => characters[random.nextInt(characters.length)],
    ).join();

    return generatedCode;
  }

  static Future<String> generateUniqueCode() async {
    String generatedCode = generateCode();
    bool isUnique = false;

    while (!isUnique) {
      if (await FirestoreFunctions.isCodeUnique(code: generatedCode)) {
        isUnique = true;
      } else {
        generatedCode = generateCode();
      }
    }

    return generatedCode;
  }
}
