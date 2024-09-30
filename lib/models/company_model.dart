import 'package:geolocation_attendance_tracker/models/branch_model.dart';
import 'package:geolocation_attendance_tracker/models/offsite_model.dart';

class Company {
  const Company({
    required this.name,
    required this.branches,
    required this.employeeCode,
    required this.adminCode,
    required this.offsites,
  });

  final String name;
  final List<Branch> branches;
  final List<Offsite> offsites;
  final String employeeCode;
  final String adminCode;

  factory Company.fromFirestore(Map<String, dynamic> json) {
    final List<Branch> branches = [];
    if (json['branches'] != null) {
      json['branches'].forEach((branch) {
        branches.add(Branch.fromFirestore(branch));
      });
    }

    final List<Offsite> offsites = [];
    if (json['offsites'] != null) {
      json['offsites'].forEach((offsite) {
        offsites.add(Offsite.fromFirestore(offsite));
      });
    }

    return Company(
      name: json['name'],
      branches: branches,
      employeeCode: json['employee_code'],
      adminCode: json['admin_code'],
      offsites: offsites,
    );
  }
}
