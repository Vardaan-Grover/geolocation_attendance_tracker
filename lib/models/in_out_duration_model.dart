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
  double? durationInMinutes;
  String placeName;
  String placeAddress;

  void updateOutTimeAndMilliseconds(Timestamp value) {
    outTime = value;
    durationInMinutes = outTime!.toDate().difference(inTime.toDate()).inMinutes.toDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'in_time': inTime,
      'out_time': outTime,
      'duration_in_minutes': durationInMinutes,
    };
  }

  factory InOutDuration.fromFirestore(Map<String, dynamic> json) {
    print('In Firestore: ${json.runtimeType}');
    print('In Time: ${json['in_time'].runtimeType}');
    print('Out Time: ${json['out_time'].runtimeType}');
    print('Duration: ${json['duration_in_minutes'].runtimeType}');
    print('Place Name: ${json['place_name'].runtimeType}');
    print('Place Address: ${json['place_address'].runtimeType}');
    return InOutDuration(
      inTime: json['in_time'],
      outTime: json['out_time'],
      durationInMinutes: json['duration_in_minutes'],
      placeName: json['place_name'],
      placeAddress: json['place_address'],
    );
  }
}
