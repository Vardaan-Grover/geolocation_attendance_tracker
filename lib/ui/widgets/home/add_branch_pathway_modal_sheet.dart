import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';

class AddBranchPathwayModalSheet extends StatelessWidget {
  const AddBranchPathwayModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(largeSpacing),
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PathwayButton(
            title: 'By Map',
            icon: Icons.map,
            onPressed: () {},
          ),
          SizedBox(width: mediumSpacing),
          PathwayButton(
            title: 'By Current Location',
            icon: Icons.my_location,
            onPressed: () {},
          ),
          SizedBox(width: mediumSpacing),
          PathwayButton(
            title: 'By Raw Input',
            icon: Icons.location_on_outlined,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class PathwayButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() onPressed;

  const PathwayButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        height: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              SizedBox(height: smallSpacing),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
