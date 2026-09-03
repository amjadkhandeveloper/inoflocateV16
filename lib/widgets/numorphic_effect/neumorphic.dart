import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_colors.dart';

class NeumorphicEffect extends StatelessWidget {
  const NeumorphicEffect({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // width: 500.0,
      // height: 500.0,
      // color: const Color(0xffecf0f3),
      alignment: Alignment.center,
      transformAlignment: Alignment.center,
      child: Container(
          // width: 200,
          // height: 200,
          decoration: BoxDecoration(
            // color: const Color(0xffecf0f3),
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode
                    ? AppColors.numorphicDarkModeColor
                    : AppColors.numorphicLightModeColor,
                isDarkMode
                    ? AppColors.numorphicDarkModeColor
                    : AppColors.numorphicLightModeColor,
                // Color(0xffecf0f3),
                // Color(0xffecf0f3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? AppColors.numorphicDarkModeShadowColorLight
                    : AppColors.numorphicLightModeShadowColorLight,
                offset: const Offset(-5.0, -8.0),
                blurRadius: 10,
                spreadRadius: 0.0,
              ),
              BoxShadow(
                color: isDarkMode
                    ? AppColors.numorphicDarkModeShadowColorDark
                    : AppColors.numorphicLightModeShadowColorDark,
                offset: const Offset(2.0, 5.0),
                blurRadius: 8,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: child),
    );
  }
}
