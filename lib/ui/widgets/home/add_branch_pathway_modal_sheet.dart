import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocation_attendance_tracker/constants.dart';
import 'package:geolocation_attendance_tracker/models/user_model.dart';
import 'package:geolocation_attendance_tracker/ui/screens/branch/pin_on_map_screen.dart';
import 'package:geolocation_attendance_tracker/ui/widgets/home/branch_raw_coordinates_modal_sheet.dart';

class AddBranchPathwayModalSheet extends StatelessWidget {
  final User user;

  const AddBranchPathwayModalSheet(this.user, {super.key});

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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PinOnMapScreen(user),
                ),
              );
            },
          ),
          SizedBox(width: mediumSpacing),
          PathwayButton(
            title: 'By Raw Input',
            icon: Icons.location_on_outlined,
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => BranchRawCoordinatesModalSheet(user));
            },
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
