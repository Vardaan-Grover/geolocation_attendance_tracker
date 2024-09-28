import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialSuperFilters = {
  'fullName': '',
  'email': '',
  'password': '',
  'companyName': null,
  'adminCode': null,
  'employeeCode': null
};

class UserNotifier extends StateNotifier<Map<String, dynamic>> {
  UserNotifier() : super(initialSuperFilters);

  void updateFullName(String value) {
    state = {...state, 'fullName': value};
  }

  void updateEmail(String value) {
    state = {...state, 'email': value};
  }

  void updatePassword(String value) {
    state = {...state, 'password': value};
  }

  void updateCompanyName(String value) {
    state = {
      ...state,
      'companyName': value,
      'adminCode': null,
      'employeeCode': null,
    };
  }
  void updateAdminCode(String value) {
    state = {
      ...state,
      'companyName': null,
      'adminCode': value,
      'employeeCode': null,
    };
  }
  void updateEmployeeCode(String value) {
    state = {
      ...state,
      'companyName': null,
      'adminCode': null,
      'employeeCode': value,
    };
  }
}

// Create a provider for the UserNotifier
final userProvider = StateNotifierProvider<UserNotifier, Map<String, dynamic>>((ref) {
  return UserNotifier();
});
