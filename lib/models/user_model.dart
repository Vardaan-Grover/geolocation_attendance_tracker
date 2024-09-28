import 'package:geolocation_attendance_tracker/models/in_out_duration_model.dart';

class User {
  User({
    required this.fullName,
    required this.role,
    required this.associatedCompanyId,
    this.selectedBranchCoordinates,
    this.tracking,
  });

  final String fullName;
  final String role;
  final String associatedCompanyId;
  List<double>? selectedBranchCoordinates;
  Map<String, List<InOutDuration>>? tracking;

  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      fullName: data['full_name'] as String,
      role: data['role'] as String,
      associatedCompanyId: data['associated_company_id'] as String,
      selectedBranchCoordinates: data['selected_branch_coordinates'] != null
          ? List<double>.from(data['selectedBranchCoordinates'] as List<dynamic>)
          : null,
      tracking: data['tracking'] != null
          ? Map<String, List<InOutDuration>>.from(data['tracking'] as Map)
          : null,
    );
  }
}
