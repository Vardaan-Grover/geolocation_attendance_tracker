import 'package:geolocation_attendance_tracker/models/branch_model.dart';

class Company {
  const Company({
    required this.name,
    required this.branches,
    required this.memberCode,
    required this.adminCode,
  });

  final String name;
  final Map<String, Branch> branches;
  final String memberCode;
  final String adminCode;
}
