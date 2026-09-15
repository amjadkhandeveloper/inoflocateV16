import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Shows a short bottom toast — used by providers on [Failure] and success messages.
customToast({
  required String? message,
  Color? color,
}) {
  final text = (message ?? '').trim();
  if (text.isEmpty) return;
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
}
