import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/ui/screens/employee_attendence_screen.dart';

class EmployeesScreen extends StatefulWidget {
  final User user;

  const EmployeesScreen(this.user, {super.key});

  @override
  State<EmployeesScreen> createState() => EmployeesScreenState();
}

class EmployeesScreenState extends State<EmployeesScreen> {
  late Future<Map<String, User>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch employees using the associated company ID of the user
    _employeesFuture = FirestoreFunctions.fetchEmployeesForCompany(
        widget.user.associatedCompanyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees of ${widget.user.fullName}\'s Company'),
      ),
      body: FutureBuilder<Map<String, User>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading spinner
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching employees: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No employees found.'));
          } else if (snapshot.hasData) {
            final employees = snapshot.data!;
            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(employees.values.elementAt(index).fullName),
                  subtitle: Text(employees.values.elementAt(index).role),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Handle edit employee action
                    },
                  ),
                  onTap: () {
                    // Navigate to EmployeeAttendanceScreen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeAttendanceScreen(
                          user: employees.values.elementAt(index),
                          userId: employees.keys.elementAt(index),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('Unexpected error occurred.'));
          }
        },
      ),
    );
  }
}
