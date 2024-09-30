import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/company_model.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';

class UserInfoHeader extends StatelessWidget {
  final Company company;
  final User user;

  const UserInfoHeader({
    super.key,
    required this.company,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    const roleTitleMap = {'super-admin': 'Super Admin', 'admin': 'Admin'};

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Center(
            child: Icon(
              Icons.person,
              color: colorScheme.onPrimaryContainer,
              size: 42,
            ),
          ),
        ),
        SizedBox(width: mediumSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.fullName} (${roleTitleMap[user.role]})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(company.name, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}