import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckInCheckOutScreen extends StatelessWidget {
  final DateTime date;
  final String checkIn;
  final String checkOut;

  const CheckInCheckOutScreen({
    super.key,
    required this.date,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy-MM-dd').format(date)),
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
            Text('Check-in: $checkIn'),
            const SizedBox(height: 8),
            Text('Check-out: $checkOut'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
