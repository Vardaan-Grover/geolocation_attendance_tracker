import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocation_attendance_tracker/services/helper_functions.dart';

class FirestoreFunctions {
  static final CollectionReference companiesCollection =
      FirebaseFirestore.instance.collection('companies');
  static final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Checks whether generated code is unique and not being used by any other company.
  ///
  /// Parameters:
  /// - `code`: The code to be checked.
  ///
  /// Returns:
  /// - `true`: If the code is unique.
  /// - `false`: If the code is not unique.
  static Future<bool> isCodeUnique({required String code}) async {
    try {
      final memberCodeSnapshot =
          await companiesCollection.where('member_code', isEqualTo: code).get();
      final adminCodeSnapshot =
          await companiesCollection.where('admin_code', isEqualTo: code).get();

      if (memberCodeSnapshot.docs.isEmpty && adminCodeSnapshot.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Creates a new company in the Firestore database.
  ///
  /// This function requires the only the company name.
  ///
  /// Parameters:
  /// - `name`: The name of the company.
  ///
  /// Returns:
  /// - `companyId`: If the company was created successfully. This can be used to link users back to the company.
  ///
  /// OR
  ///
  /// - *error message*: If the company creation failed.
  static Future<String> createCompany({required String name}) async {
    try {
      final companyId = companiesCollection.doc().id;
      final memberCode = await HelperFunctions.generateUniqueCode();
      final adminCode = await HelperFunctions.generateUniqueCode();

      await companiesCollection.doc(companyId).set({
        'name': name,
        'branches': {},
        'member_code': memberCode,
        'admin_code': adminCode,
      });

      return companyId;
    } catch (e) {
      return e.toString();
    }
  }

  /// Finds the company ID using the member code.
  ///
  /// Parameters:
  /// - `code`: The member code entered by the user.
  ///
  /// Returns:
  /// - `companyId`: If the company was found.
  /// - `null`: If the company was not found for given code.
  /// - `error message`: If an error occurred. The message will start with *"Error: "*.
  static Future<String?> findCompanyIdByMemberCode(String code) async {
    try {
      final querySnapshot =
          await companiesCollection.where("member_code", isEqualTo: code).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  /// Creates a new user in the Firestore database.
  ///
  /// Needs to be called at the end of the user onboarding process.
  ///
  /// Parameters:
  /// - `fullName`: The full name of the user.
  /// - `role`: The role assigned to the user. Possible values: '*super-admin*', '*admin*', or '*employee*'.
  /// - `selectedBranch`: The branch selected by the user.
  /// - `code`: The company code (member or admin level).
  static createUser({
    required String fullName,
    required String role,
    required String associatedCompanyId,
  }) {}
}
