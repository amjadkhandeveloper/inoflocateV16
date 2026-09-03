import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar(
      {super.key, this.icon, this.bgColor, this.foregroundColor});
  // final IconData? icon;
  final Color? bgColor;
  final Color? foregroundColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: bgColor ?? Theme.of(context).cardColor,
        foregroundColor: foregroundColor,
        // radius: 25,
        child: icon
        // Icon(
        //   icon ?? Icons.local_activity_rounded,
        //   // size: 25,
        // ),
        );
  }
}
