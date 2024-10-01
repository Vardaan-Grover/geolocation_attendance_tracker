import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'checkin_checkout_screen.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  final String userId;
  final User user;

  const EmployeeAttendanceScreen({
    super.key,
    required this.userId,
    required this.user,
  });

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  DateTime _focusedDay = DateTime.now(); // The current focused date
  DateTime? _selectedDay; // The day that the user selects

  // Function to handle day selection and navigate to CheckInCheckOutScreen
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay; // Update focused day as well
    });

    // Navigate to the check-in and check-out details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckInCheckOutScreen(
          date: selectedDay,
          uid: widget.userId,
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.fullName), // Display the user's full name
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Attendance History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // TableCalendar widget
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
