import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/in_out_duration_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CheckInCheckOutScreen extends StatefulWidget {
  final DateTime date;
  final String uid; // Assuming the user ID is passed in as well

  const CheckInCheckOutScreen({
    super.key,
    required this.date,
    required this.uid,
  });

  @override
  State<CheckInCheckOutScreen>  createState() => _CheckInCheckOutScreenState();
}

class _CheckInCheckOutScreenState extends State<CheckInCheckOutScreen> {
  final List<InOutDuration> inOutDurations = [];

  // Simulated stream for demonstration purposes. Replace with your actual backend stream.
  Stream<DateTime> get checkInCheckOutStream async* {
    await Future.delayed(const Duration(seconds: 1));
    yield DateTime.now();
    await Future.delayed(const Duration(seconds: 5));
    yield DateTime.now().add(const Duration(minutes: 10));
    await Future.delayed(const Duration(seconds: 5));
    yield DateTime.now().add(const Duration(minutes: 20));
  }

  // Function to update the tracking in Firestore
  Future<void> updateTrackingBackend(Timestamp checkIn, Timestamp? checkOut) async {
    InOutDuration? lastRecord;

    if (inOutDurations.isNotEmpty && inOutDurations.last.outTime == null) {
      lastRecord = inOutDurations.last;
      lastRecord.updateOutTimeAndMilliseconds(checkOut!);
    } else {
      lastRecord = InOutDuration(
        inTime: checkIn,
        placeName: 'Office',
        placeAddress: 'Office Address',
      );
      inOutDurations.add(lastRecord);
    }

    final result = await updateTracking(
      uid: widget.uid,
      date: DateFormat('yyyy-MM-dd').format(widget.date),
      obj: lastRecord,
    );

    if (result != 'success') {
      // Handle failure case
      print("Error updating tracking data");
    } else {
      setState(() {}); // Update UI after success
    }
  }

  // Function to calculate the time difference between check-in and check-out
  String calculateTimeDifference(double? durationInMinutes) {
    if (durationInMinutes == null) return '-';
    final hours = (durationInMinutes / 60).floor();
    final minutes = (durationInMinutes % 60).toInt();
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy-MM-dd').format(widget.date)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check-in and Check-out Times',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<DateTime>(
              stream: checkInCheckOutStream, // Replace with actual backend stream
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (inOutDurations.isEmpty || inOutDurations.last.outTime != null) {
                    updateTrackingBackend(Timestamp.fromDate(snapshot.data!), null);
                  } else {
                    updateTrackingBackend(
                      inOutDurations.last.inTime,
                      Timestamp.fromDate(snapshot.data!),
                    );
                  }
                }

                return Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        _buildTableHeader(),
                        ..._buildTableRows(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Table header row
  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[300]),
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Check-out', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Dynamically builds table rows for check-ins, check-outs, and duration
  List<TableRow> _buildTableRows() {
    return List.generate(inOutDurations.length, (index) {
      final duration = inOutDurations[index];

      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(DateFormat('HH:mm').format(duration.inTime.toDate())),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: duration.outTime != null
                ? Text(DateFormat('HH:mm').format(duration.outTime!.toDate()))
                : const Text('Pending'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(calculateTimeDifference(duration.durationInMinutes)),
          ),
        ],
      );
    });
  }
}

// Replace this with the actual updateTracking function that works with Firestore
Future<String> updateTracking({
  required String uid,
  required String date,
  required InOutDuration obj,
}) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty) {
        final tracking = data['tracking'] as Map<String, dynamic>;
        if (tracking.containsKey(date)) {
          final List<dynamic> updatedList = tracking[date];
          updatedList.add(obj.toMap());
          tracking[date] = updatedList;
        } else {
          tracking[date] = [obj.toMap()];
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).update({"tracking": tracking});
        return 'success';
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          "tracking": {
            date: [obj.toMap()]
          }
        });
        return 'success';
      }
    } else {
      return 'failure: document does not exist';
    }
  } catch (e) {
    return 'failure: $e';
  }
}
