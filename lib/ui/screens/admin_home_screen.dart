import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';

import 'package:geolocation_attendance_tracker/services/firestore_functions.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';

class AdminHomeScreen extends StatefulWidget {
  final User user;

  const AdminHomeScreen(this.user, {super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Company? company;

  void getCompany() async {
    final fetchedCompany =
        await FirestoreFunctions.fetchCompany(widget.user.associatedCompanyId);

    if (fetchedCompany != null) {
      setState(() {
        company = fetchedCompany;
      });
    } else {
      print('Company not found');
    }
  }

  @override
  void initState() {
    super.initState();
    getCompany();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company != null ? company!.name : "Loading..."),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.user.role),
          Text(widget.user.fullName),
        ],
      ),
    );
  }
}
