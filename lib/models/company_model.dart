import 'package:geolocation_attendance_tracker/models/branch_model.dart';

class Company {
  const Company({
    required this.name,
    required this.branches,
    required this.employeeCode,
    required this.adminCode,
  });

  final String name;
  final List<Branch> branches;
  final String employeeCode;
  final String adminCode;
}
