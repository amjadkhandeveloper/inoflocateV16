import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infolocate/screens/card_types_screen/model/card_type_model.dart';
import 'package:infolocate/screens/card_types_screen/model/card_type_setting_model.dart';
import 'package:infolocate/screens/login/model/client_model.dart';
import 'package:infolocate/screens/login/model/user_login_response_model.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';

/// Allows HTTPS calls to servers with self-signed or staging certificates.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// App entry: initializes Hive, localization, theme, then runs [MyApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialiseData();
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ja'),
        Locale('es'),
        Locale('hi'),
        Locale('kn'),
        Locale('ta'),
        Locale('te'),
        Locale('ur'),
        Locale('bn')
        // Locale('en', 'US'),
        // Locale('ja', 'JA'),
        // Locale('es', 'ES'),
        // Locale('hi', 'HI'),
        // Locale('ka', 'KA'),
        // Locale('ta', 'TA'),
        // Locale('te', 'TE'),
        // Locale('ur', 'UR')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

/// Runs all startup work before [runApp]: theme mode, Hive, orientation, i18n.
initialiseData() async {
  Global.savedThemeMode = await AdaptiveTheme.getThemeMode();
  await Future.wait([
    _openHiveBox(),
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    ),
    EasyLocalization.ensureInitialized()
  ]);
}

/// Opens Hive, registers type adapters, and hydrates [Global] from local storage.
Future _openHiveBox() async {
  var dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  registerHiveAdapters();
  await AppHelper.getHiveBoxData();
  return;
}

/// Registers Hive adapters for login/session models persisted across app restarts.
registerHiveAdapters() {
  Hive.registerAdapter(UserLoginResponseModelDataUserAdapter());
  Hive.registerAdapter(ClientModelDataClientAdapter());
  Hive.registerAdapter(CardTypeModelAdapter());
  Hive.registerAdapter(CardTypeSettingAdapter());
}
