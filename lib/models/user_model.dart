import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocation_attendance_tracker/models/in_out_duration_model.dart';
import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';

class User {
  User({
    required this.fullName,
    required this.role,
    required this.associatedCompanyId,
    this.selectedBranch,
    this.tracking,
  });

  final String fullName;
  final String role;
  final String associatedCompanyId;
  String? selectedBranch;
  Map<String, List<InOutDuration>>? tracking;
}
