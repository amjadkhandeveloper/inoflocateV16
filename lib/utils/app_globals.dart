import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:hive/hive.dart';

import '../screens/login/model/client_model.dart';
import '../screens/login/model/user_login_response_model.dart';

/// App-wide in-memory cache loaded from Hive on startup ([AppHelper.getHiveBoxData]).
///
/// Session flow:
/// 1. [savedLanguageCode] / [savedContryCode] — set on language screen.
/// 2. [savedClientAuthData] — set after client login (includes per-client [clientUrl]).
/// 3. [savedUserAuthData] — set after user login (dashboard and vehicle APIs use this).
class Global {
  static final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');

  // --- Persisted session & preferences (Hive) ---
  static Color? savedPrimeryColor;
  static UserLoginResponseModelDataUser? savedUserAuthData;
  static ClientModelDataClient? savedClientAuthData;
  // static CardTypeSetting? cardTypeSetting;

  static String? savedLanguageCode;
  static int? savedContryCode;
  static int? savedVehicleStatusCardTypeId;
  static int? savedAlertStatusCardTypeId;
  static late Box<dynamic> box;
  static bool isVehicleListBackgroundFetching = false;
  static bool locationPermission = false;

// /^$|\s+/
  static final spaceValidator =
      RegExp(r"/^(?!\s*$).+/"); //* checks first letter not empty
  static final RegExp passwordRegExp =
      RegExp(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{4,})");
  static AdaptiveThemeMode? savedThemeMode;
}
