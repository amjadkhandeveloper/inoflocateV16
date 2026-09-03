import 'package:flutter/material.dart';

class AppColors {
  static final MaterialColor primeryColor = MaterialColor(
      0xFFFF0000, colorValues); //primary color of type MatrialColor

  static const Color grey = Color(0xfff4f3f3);
  static const Color customGrey = Color(0xffADADAD);
  static const Color lightGrey = Color(0xffA8A8A9);
  static const Color darkGrey = Color(0xff6B6A6A);

  //* for light mode neumorphic
  static Color numorphicLightModeColor = const Color(0xffecf0f3);
  static Color numorphicLightModeShadowColorLight = const Color(0xffffffff);
  static Color numorphicLightModeShadowColorDark =
      const Color.fromARGB(255, 216, 221, 224);
  //******

  //* for light mode neumorphic
  static Color numorphicDarkModeColor = const Color(0xff333333);
  static Color numorphicDarkModeShadowColorLight = const Color(0xff515151);
  static Color numorphicDarkModeShadowColorDark = const Color(0xff151515);
  //******
}

const Color primeryColorConstant =
    Color(0xff0065FF); //primary color of type Color

Map<int, Color> colorValues = const {
  50: Color.fromRGBO(0, 0, 255, .1),
  100: Color.fromRGBO(0, 0, 255, .2),
  200: Color.fromRGBO(0, 0, 255, .3),
  300: Color.fromRGBO(0, 0, 255, .4),
  400: Color.fromRGBO(0, 0, 255, .5),
  500: Color.fromRGBO(0, 0, 255, .6),
  600: Color.fromRGBO(0, 0, 255, .7),
  700: Color.fromRGBO(0, 0, 255, .8),
  800: Color.fromRGBO(0, 0, 255, .9),
  900: Color.fromRGBO(0, 0, 255, 1),
};
