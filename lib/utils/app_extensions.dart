import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

//for creating sized box
extension AddEmptySpace on num {
  SizedBox get height => SizedBox(height: toDouble());

  SizedBox get width => SizedBox(width: toDouble());
}
extension ToMaterial on Color? {
  MaterialColor? toMaterial() {
    // print("to hex ${this!.toIntColor()}");
    return MaterialColor(this!.toIntColor() ?? 0xFF0065ff, {
      50: Color(this!.toIntColor()!).withOpacity(.1),
      100: Color(this!.toIntColor()!).withOpacity(.2),
      200: Color(this!.toIntColor()!).withOpacity(.3),
      300: Color(this!.toIntColor()!).withOpacity(.4),
      400: Color(this!.toIntColor()!).withOpacity(.5),
      500: Color(this!.toIntColor()!).withOpacity(.6),
      600: Color(this!.toIntColor()!).withOpacity(.7),
      700: Color(this!.toIntColor()!).withOpacity(.8),
      800: Color(this!.toIntColor()!).withOpacity(.9),
      900: Color(this!.toIntColor()!).withOpacity(.10),
    });
  }
}

extension ToIntColor on Color? {
  int? toIntColor() {
    String hexColor = this!.toHex();
    // log("hex  color is $hexColor");
    String subString = '0xFF${hexColor.substring(3)}';
    // log("converted int color is ${subString}");
    return int.tryParse(
      subString,
    );
  }
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

///* below dunction is to check which color visible clearly on selected color

bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
  // Old:
  // return 1.05 / (color.computeLuminance() + 0.05) > 4.5;

  // New:
  int v = sqrt(pow(backgroundColor.red, 2) * 0.299 +
          pow(backgroundColor.green, 2) * 0.587 +
          pow(backgroundColor.blue, 2) * 0.114)
      .round();
  return v < 130 + bias ? true : false;
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }
}

extension DateTimeHelper on String {
  DateTime toDateTime() => DateFormat("yyyy-MM-dd hh:mm:ss").parse(this);
}

extension TimeOfDayExtension on TimeOfDay {
  int compareToTime(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}
