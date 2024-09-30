import 'package:cloud_firestore/cloud_firestore.dart';

class InOutDuration {
  InOutDuration({
    required this.inTime,
    required this.placeName,
    required this.placeAddress,
    this.outTime,
    this.durationInMinutes,
  });

  final Timestamp inTime;
  Timestamp? outTime;
  int? durationInMinutes;
  String placeName;
  String placeAddress;

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