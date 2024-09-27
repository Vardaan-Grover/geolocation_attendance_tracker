import 'package:cloud_firestore/cloud_firestore.dart';

class InOutDuration {
  InOutDuration({
    required this.inTime,
    this.outTime,
    this.durationInMinutes,
  });

  final Timestamp inTime;
  Timestamp? outTime;
  int? durationInMinutes;

  void updateOutTimeAndMilliseconds(Timestamp value) {
    outTime = value;
    durationInMinutes = outTime!.toDate().difference(inTime.toDate()).inMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'in_time': inTime,
      'out_time': outTime,
      'duration_in_minutes': durationInMinutes,
    };
  }
}