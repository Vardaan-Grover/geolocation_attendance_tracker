import 'package:cloud_firestore/cloud_firestore.dart';

class InOutDurationModel {
  InOutDurationModel({
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
}