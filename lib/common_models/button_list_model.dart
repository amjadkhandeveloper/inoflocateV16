import 'package:flutter/cupertino.dart';

class ButtonListModel {
  final Widget? icon;
  final String? title;
  final String? value;
  final Function()? onTap;

  ButtonListModel({
    this.icon,
    this.title,
    this.value,
    this.onTap,
  });
}