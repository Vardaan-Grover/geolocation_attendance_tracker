import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/ui/screens/checkin_checkout_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  final String employeeName;

  const EmployeeAttendanceScreen({super.key, required this.employeeName});

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  DateTime _focusedDay = DateTime.now(); // The current focused date
  DateTime? _selectedDay; // The day that the user selects
  String _selectedMonth =
      DateFormat('MMM yyyy').format(DateTime.now()); // Default formatted month

  bool _isCalendarVisible =
      true; // Control visibility between calendar and list

  // Dummy data for check-in and check-out
  final Map<DateTime, List<String>> _attendanceData = {
    DateTime.utc(2024, 10, 1): ['09:00 AM', '05:00 PM'],
    DateTime.utc(2024, 10, 2): ['09:15 AM', '05:10 PM'],
    DateTime.utc(2024, 10, 3): ['09:30 AM', '05:30 PM'],
  };

  // Function to show the modal bottom sheet for selecting month and year
  void _showMonthYearPicker() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Year and Month',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity, // Full-width button
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _focusedDay,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2100),
                      helpText: 'Select Year and Month',
                      fieldLabelText: 'Year and Month',
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _focusedDay = selectedDate;
                        _selectedMonth = DateFormat('MMM yyyy')
                            .format(selectedDate); // Format as "Oct 2024"
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Pick Month and Year'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle day selection and show dialog for past or present dates
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay; // Update focused day as well
    });

    // Check if the selected day is today or before
    if (selectedDay.isBefore(DateTime.now()) ||
        isSameDay(selectedDay, DateTime.now())) {
      _showWorkingHoursDialog(selectedDay); // Show dialog with working hours
    }
  }

  // Show the working hours dialog
  void _showWorkingHoursDialog(DateTime date) {
    String checkIn = _attendanceData[date]?[0] ?? 'N/A';
    String checkOut = _attendanceData[date]?[1] ?? 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Total Working Hours"),
          content: Text("Check-in: $checkIn\nCheck-out: $checkOut"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Navigate to the check-in and check-out details screen
  void _openAttendanceDetailScreen(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckInCheckOutScreen(
          date: date,
          checkIn: _attendanceData[date]?[0] ?? 'N/A',
          checkOut: _attendanceData[date]?[1] ?? 'N/A',
          
        ),
      ),
    );
  }

  // Function to toggle between calendar and list view
  void _toggleView() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Attendance History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber, // Set background color for the row
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance For',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _showMonthYearPicker,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedMonth, // Display formatted month (e.g., Oct 2024)
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle button for switching between calendar and list view
            GestureDetector(
              onTap: _toggleView,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isCalendarVisible ? 'Show List View' : 'Show Calendar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Conditionally show the calendar or list view
            Expanded(
              child: _isCalendarVisible
                  ? TableCalendar(
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
                    )
                  : ListView.builder(
                      itemCount: _attendanceData.keys.length,
                      itemBuilder: (context, index) {
                        DateTime date = _attendanceData.keys.elementAt(index);
                        return ListTile(
                          title: Text(DateFormat('yyyy-MM-dd').format(date)),
                          subtitle: const Text('Click to view details'),
                          onTap: () {
                            _openAttendanceDetailScreen(date);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
