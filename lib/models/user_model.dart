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
}
