import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_extensions.dart';

import 'app_colors.dart';
import 'app_localization_key.dart';
import 'app_ui.dart';

class AppStyles {
  static ThemeData appLightTheme(
          {Color? primaryColor,
          required BuildContext ctx,
          String? fontFamily = montserrat}) =>
      ThemeData(
        useMaterial3: true,
        primarySwatch: primaryColor == null
            ? primeryColorConstant.toMaterial()
            : primaryColor.toMaterial(),
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primaryColor ?? primeryColorConstant,
          onPrimary: Colors.white,
          secondary: AppUi.accent,
          onSecondary: Colors.white,
          surface: AppUi.cardLight,
          onSurface: AppUi.inkLight,
          error: const Color(0xFFDC2626),
          onError: Colors.white,
        ),
        canvasColor: AppUi.pageBgLight,
        cardColor: AppUi.cardLight,
        dividerColor: AppUi.lineLight,
        iconTheme: const IconThemeData(color: AppUi.inkLight),
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: AppUi.inkLight),
          titleTextStyle:
              AppStyles.textStyle2(context: ctx, color: AppUi.inkLight),
          elevation: 0,
          backgroundColor: AppUi.cardLight,
          foregroundColor: AppUi.inkLight,
          surfaceTintColor: Colors.transparent,
        ),
        fontFamily: fontFamily,
        scaffoldBackgroundColor: AppUi.pageBgLight,
      );

  static ThemeData appDarkTheme(
          {Color? primaryColor,
          required BuildContext ctx,
          String? fontFamily = montserrat}) =>
      ThemeData(
        useMaterial3: true,
        primarySwatch: primaryColor == null
            ? primeryColorConstant.toMaterial()
            : primaryColor.toMaterial(),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: primaryColor ?? primeryColorConstant,
          onPrimary: Colors.white,
          secondary: AppUi.accent,
          onSecondary: Colors.white,
          surface: AppUi.cardDark,
          onSurface: AppUi.inkDark,
          error: const Color(0xFFDC2626),
          onError: Colors.white,
        ),
        canvasColor: AppUi.pageBgDark,
        cardColor: AppUi.cardDark,
        dividerColor: AppUi.lineDark,
        iconTheme: const IconThemeData(color: AppUi.inkDark),
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: AppUi.inkDark),
          titleTextStyle:
              AppStyles.textStyle2(context: ctx, color: AppUi.inkDark),
          elevation: 0,
          backgroundColor: AppUi.cardDark,
          foregroundColor: AppUi.inkDark,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: AppUi.pageBgDark,
        fontFamily: fontFamily,
      );

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
