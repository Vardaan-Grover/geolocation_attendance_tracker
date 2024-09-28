import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/in_out_duration_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
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
  static Future<bool> isCodeUnique(String code) async {
    try {
      final employeeCodeSnapshot = await companiesCollection
          .where('employee_code', isEqualTo: code)
          .get();
      final adminCodeSnapshot =
          await companiesCollection.where('admin_code', isEqualTo: code).get();

      if (employeeCodeSnapshot.docs.isEmpty && adminCodeSnapshot.docs.isEmpty) {
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
  /// - `error message`: If the company creation failed.
  static Future<String> createCompany({required String name}) async {
    try {
      final companyId = companiesCollection.doc().id;
      final employeeCode = await HelperFunctions.generateUniqueCode();
      final adminCode = await HelperFunctions.generateUniqueCode();

      await companiesCollection.doc(companyId).set({
        'name': name,
        'branches': [],
        'employee_code': employeeCode,
        'admin_code': adminCode,
      });

      return companyId;
    } catch (e) {
      return e.toString();
    }
  }

  /// Finds the company ID using the employee code.
  ///
  /// Parameters:
  /// - `code`: The employee code entered by the user.
  ///
  /// Returns:
  /// - `companyId`: If the company was found.
  /// - `null`: If the company was not found for given code.
  /// - `error message`: If an error occurred. The message will start with *"Error: "*.
  static Future<String?> findCompanyIdByEmployeeCode(String code) async {
    try {
      final querySnapshot = await companiesCollection
          .where("employee_code", isEqualTo: code)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  /// Finds the company ID using the employee code.
  ///
  /// Parameters:
  /// - `code`: The employee code entered by the user.
  ///
  /// Returns:
  /// - `companyId`: If the company was found.
  /// - `null`: If the company was not found for given code.
  /// - `error message`: If an error occurred. The message will start with *"Error: "*.
  static Future<String?> findCompanyByAdminCode(String code) async {
    try {
      final querySnapshot =
          await companiesCollection.where("admin_code", isEqualTo: code).get();
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
  /// Needs to be called at the end of the user onboarding process. Also, the user must be logged in to call this function properly.
  ///
  /// Parameters:
  /// - `uid`: The unique ID used to identify a user. This is generated by Firebase Authentication.
  /// - `fullName`: The full name of the user.
  /// - `role`: The role assigned to the user. Possible values: '*super-admin*', '*admin*', or '*employee*'.
  /// - `associatedCompanyId`: The unique ID used to identify a company.
  ///
  /// Returns:
  /// - `"success"`: If the user was created successfully.
  /// - `error message`: If the user creation failed.
  static Future<String> createUser({
    required String uid,
    required String fullName,
    required String role,
    required String associatedCompanyId,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        'full_name': fullName,
        'role': role,
        'associated_company_id': associatedCompanyId,
        if (role == 'employee') 'selected_branch_coordinates': [],
        if (role == 'employee') 'tracking': {},
      });

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  /// Fetches the user data using the user ID.
  ///
  /// Parameters:
  /// - `uid`: The unique ID of the user.
  ///
  /// Returns:
  /// - A `User` object if the user was found.
  /// - `null`: If the user was not found.
  static Future<User?> fetchUser(String uid) async {
    try {
      final docSnapshot = await usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty) {
          return User.fromFirestore(data);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches the company data using the company ID.
  ///
  /// Parameters:
  /// - `companyId`: The ID of the company.
  ///
  /// Returns:
  /// - A `Company` object if the company was found.
  /// - `null`: If the company was not found.
  static Future<Company?> fetchCompany(String companyId) async {
    try {
      final docSnapshot = await companiesCollection.doc(companyId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty) {
          return Company.fromFirestore(data);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches the branches of a company using the company ID.
  ///
  /// Parameters:
  /// - `companyId`: The ID of the company.
  ///
  /// Returns:
  /// - A list of `Branch` objects if the branches were found. Else, an empty list.
  static Future<List<Branch>> fetchBranches(String companyId) async {
    try {
      final docSnapshot = await companiesCollection.doc(companyId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final branches = data['branches'] as Map<String, dynamic>;
          if (branches.isNotEmpty) {
            return branches.entries
                .map((branch) => Branch(
                    name: branch.value.name,
                    address: branch.value.address,
                    latitude: branch.value.latitude,
                    longitude: branch.value.longitude,
                    radius: branch.value.radius))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Adds a new branch to the company.
  ///
  /// Parameters:
  /// - `companyId`: The ID of the company in which you want to add this branch
  /// - `branch`: The `Branch` object you want to add.
  ///
  /// Returns:
  /// - `"success"`: If branch added successfully
  /// - `error message`: If some error occurred
  static Future<String> addBranch({
    required String companyId,
    required Branch branch,
  }) async {
    try {
      final docSnapshot = await companiesCollection.doc(companyId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final branches = data['branches'] as List<dynamic>;
          final List<Map<String, dynamic>> updatedBranches = [
            ...branches,
            branch.toMap()
          ];

          await companiesCollection
              .doc(companyId)
              .update({"branches": updatedBranches});

          return 'success';
        }
      }

      return 'Some error occurred. Please try again later';
    } catch (e) {
      return e.toString();
    }
  }

  /// Deletes given branch from the company.
  ///
  /// Parameters:
  /// - `companyId`: The ID of the company from which you want to delete this branch
  /// - `branch`: The `Branch` object you want to delete.
  ///
  /// Returns:
  /// - `"success"`: If branch is deleted successfully
  /// - `error message`: If some error occurred
  static Future<String> deleteBranch(
      {required String companyId, required Branch branch}) async {
    try {
      final docSnapshot = await companiesCollection.doc(companyId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final branches = data['branches'] as List<dynamic>;
          branches.removeWhere((value) =>
              value['latitude'] == branch.latitude &&
              value['longitude'] == branch.longitude);

          await companiesCollection
              .doc(companyId)
              .update({"branches": branches});

          return 'success';
        }
      }

      return 'Some error occurred. Please try again later';
    } catch (e) {
      return e.toString();
    }
  }

  /// Updates the selected branch coordinates.
  ///
  /// Parameters:
  /// - `uid`: The unique ID of the user for whom you want to update the selected branch coordinates.
  /// - `branch`: The `Branch` object whose coordinates you want to use as the update.
  ///
  /// Returns:
  /// - `"success"`: If the update is successful
  /// - `error message`: If some error occurred
  static Future<String> updateSelectedBranchCoordinates({
    required String uid,
    required Branch branch,
  }) async {
    try {
      await usersCollection.doc(uid).update({
        "selected_branch_coordinates": branch.coordinates,
      });

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  /// Updates the tracking data for the user.
  ///
  /// Parameters:
  /// - `uid`: The unique ID of the user for whom you want to update the tracking data.
  /// - `date`: The date for which you want to update the tracking data.
  /// - `obj`: The `InOutDuration` object you want to add to the tracking data.
  ///
  /// Returns:
  /// - `"success"`: If the update is successful
  /// - `error message`: If some error occurred
  static Future<String> updateTracking({
    required String uid,
    required String date,
    required InOutDuration obj,
  }) async {
    try {
      final docSnapshot = await usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final tracking = data['tracking'] as Map<String, dynamic>;
          if (tracking.isNotEmpty) {
            if (tracking.containsKey(date)) {
              final List<InOutDuration> updatedList = [...tracking[date], obj];
              tracking[date] = updatedList;
            } else {
              tracking[date] = [obj];
            }

            await usersCollection.doc(uid).update({"tracking": tracking});
            return 'success';
          } else {
            await usersCollection.doc(uid).update({
              "tracking": {
                date: [obj]
              }
            });
            return 'success';
          }
        }
      }

      return "Some error occurred. Please try again later";
    } catch (e) {
      return e.toString();
    }
  }
}
