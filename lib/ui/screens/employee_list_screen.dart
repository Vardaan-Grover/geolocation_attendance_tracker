import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/services/firebase/firestore_functions.dart';

class EmployeesListScreen extends StatefulWidget {
  final User user;

  const EmployeesListScreen(this.user, {super.key});

  @override
  State<EmployeesListScreen> createState() =>  EmployeesListScreenState();
}

class EmployeesListScreenState extends State<EmployeesListScreen> {
  late Future<List<User>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch employees using the associated company ID of the user
    _employeesFuture = FirestoreFunctions.fetchEmployeesForCompany(widget.user.associatedCompanyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees of ${widget.user.fullName}\'s Company'),
      ),
      body: FutureBuilder<List<User>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading spinner
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching employees: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No employees found.'));
          } else if (snapshot.hasData) {
            final employees = snapshot.data!;
            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(employee.fullName),
                  subtitle: Text(employee.role),  // Display the employee role
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Handle edit employee action
                    },
                  ),
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
