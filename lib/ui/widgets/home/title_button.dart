import 'package:flutter/material.dart';

class TitleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() onPressed;

  const TitleButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        iconAlignment: IconAlignment.start,
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
      ),
    );
  }
}
