import 'dart:convert';

import 'package:geolocation_attendance_tracker/models/address_results_model.dart';
import 'package:geolocation_attendance_tracker/secret.dart';

import 'package:http/http.dart' as http;

class GeocodingFunction {
  /// Fetches formatted addresses for the given coordinates.
  ///
  /// Parameters:
  /// - `coordinates`: The coordinates of the place for which you want the formatted address. Should be of `[latitude, longitude]` format.
  ///
  /// Returns:
  /// - `AddressResult` object: Use the `isSuccess` getter to take appropriate steps.
  static Future<AddressResult> fetchFormattedAddressFromLatLng(
      List<double> coordinates) async {
    try {
      final List<String> formattedAddresses = [];
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates[0]},${coordinates[1]}&key=$googleApiKey";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['status'] == "OK") {
          for (final resultPart in jsonBody['results']) {
            formattedAddresses.add(resultPart['formatted_address']);
          }
          return AddressResult(addresses: formattedAddresses);
        } else {
          return AddressResult(error: "Error: ${jsonBody['status']}");
        }
      } else {
        return AddressResult(error: "HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
