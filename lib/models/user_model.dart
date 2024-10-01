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

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'role': role,
      'associated_company_id': associatedCompanyId,
      'selected_branch_coordinates': selectedBranchCoordinates,
      'tracking': tracking,
    };
  }

  factory User.fromFirestore(Map<String, dynamic> data) {
    final userMade = User(
      fullName: data['full_name'] as String,
      role: data['role'] as String,
      associatedCompanyId: data['associated_company_id'] as String,
      selectedBranchCoordinates: data['selected_branch_coordinates'] != null
          ? List<double>.from(
              data['selected_branch_coordinates'] as List<dynamic>)
          : null,
      tracking: data['tracking'] != null
          ? (data['tracking'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>)
                    .map((x) => InOutDuration.fromFirestore(x))
                    .toList(),
              ),
            )
          : null,
    );
    return userMade;
  }
}
