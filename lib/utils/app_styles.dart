import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_extensions.dart';

import 'app_colors.dart';
import 'app_localization_key.dart';

class AppStyles {
  static ThemeData appLightTheme(
          {Color? primaryColor,
          required BuildContext ctx,
          String? fontFamily = montserrat}) =>
      ThemeData(
        primarySwatch: primaryColor == null
            ? primeryColorConstant.toMaterial()
            : primaryColor.toMaterial(),
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle:
              AppStyles.textStyle2(context: ctx, color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.transparent,

          // actionsIconTheme: IconThemeData(
          //   color: Theme.of(context).iconTheme.color,
          // ),
        ),
        fontFamily: fontFamily,
        scaffoldBackgroundColor: Colors.white,
        // 'Montserrat'
      );

  static ThemeData appDarkTheme(
          {Color? primaryColor,
          required BuildContext ctx,
          String? fontFamily = montserrat}) =>
      ThemeData(
          primarySwatch: primaryColor == null
              ? primeryColorConstant.toMaterial()
              : primaryColor.toMaterial(),
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(
            // iconTheme: Theme.of(context).iconTheme,
            titleTextStyle: AppStyles.textStyle2(
              context: ctx,
              // color: Theme.of(context).iconTheme.color
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            // actionsIconTheme: IconThemeData(
            //   color: Theme.of(context).iconTheme.color,
            // ),
          ),
          fontFamily: fontFamily);

  static InputDecoration inputFieldStyle(
      {String? hintText,
      Widget? suffixIcon,
      Widget? prefixIcon,
      VoidCallback? onPressed}) {
    return
        // InputDecoration(
        //     border: InputBorder.none,
        //     enabledBorder: InputBorder.none,
        //     disabledBorder: InputBorder.none,
        //     // focusColor: Colors.white,
        //     // labelText: labelText,
        //     hintText: hintText,
        //     // labelStyle: TextStyle(color: Colors.white),
        //     prefixIcon: prefixIcon,
        //     suffixIcon: suffixIcon);
        InputDecoration(
            hintText: hintText ?? '',
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            border: const OutlineInputBorder());
  }

  static InputDecoration inputFieldTrackStyle(
      {String? hintText,
        Widget? suffixIcon,
        Widget? prefixIcon,
        VoidCallback? onPressed}) {
    return
      InputDecoration(
          hintText: LocaliazationKey.search.tr(),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          isDense: true,
          border: InputBorder.none);
  }

  // static AppBar customAppBar(
  //     {required BuildContext context, Widget? leading, List<Widget>? actions}) {
  //   return AppBar(
  //       iconTheme: Theme.of(context).iconTheme,
  //       elevation: 0,
  //       backgroundColor: Colors.transparent,
  //       leading: leading,
  //       actionsIconTheme: IconThemeData(
  //         color: Theme.of(context).iconTheme.color,
  //       ),
  //       actions: actions);
  // }

  static TextStyle textStyle1(
      {required BuildContext context, Color? color, double? fontSize}) {
    // var fontSize = 24.0;
    // if (fontChange == 1) {
    //   fontSize = 16.0;
    // } else if (fontChange == 2) {
    //   fontSize = 18.0;
    // } else if (fontChange == 3) {
    //   fontSize = 20.0;
    // } else if (fontChange == 4) {
    //   fontSize = 22.0;
    // } else if (fontChange == 5) {
    //   fontSize = 24.0;
    // } else if (fontChange == 6) {
    //   fontSize = 26.0;
    // } else if (fontChange == 7) {
    //   fontSize = 28.0;
    // } else if (fontChange == 8) {
    //   fontSize = 30.0;
    // }
    return TextStyle(
      color: color,
      fontSize: fontSize,
    );
  }

  static TextStyle textStyle2(
      {required BuildContext context, Color? color, double? fontSize = 18}) {
    // var fontSize = 20.0;
    // if (fontChange == 1) {
    //   fontSize = 12.0;
    // } else if (fontChange == 2) {
    //   fontSize = 14.0;
    // } else if (fontChange == 3) {
    //   fontSize = 16.0;
    // } else if (fontChange == 4) {
    //   fontSize = 18.0;
    // } else if (fontChange == 5) {
    //   fontSize = 20.0;
    // } else if (fontChange == 6) {
    //   fontSize = 22.0;
    // } else if (fontChange == 7) {
    //   fontSize = 24.0;
    // } else if (fontChange == 8) {
    //   fontSize = 26.0;
    // }
    return TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
    );
  }

  static TextStyle textStyle3(
      {required BuildContext context, Color? color, double? size}) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: size ?? 22,
    );
  }

  static TextStyle textStyle4(
      {required BuildContext context,
      bool isBold = false,
      Color? color,
      double? size}) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
    );
  }

  static TextStyle textStyle5(
      {required BuildContext context, bool isBold = false, Color? color}) {
    return TextStyle(
      fontSize: 12,
      color: color,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
    );
  }

  static TextStyle infoLocateTextStyle(
      {required BuildContext context, Color? color}) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
      fontSize: 36,
    );
  }
}
