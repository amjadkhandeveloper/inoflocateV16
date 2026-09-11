import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:infolocate/screens/dashboard/controller/ads_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'screens/language/controller/language_provider.dart';
import 'screens/login/controller/client_provider.dart';
import 'package:infolocate/screens/alerts/controller/alert_provider.dart';
import 'package:infolocate/screens/card_types_screen/controller/card_type_provider.dart';
import 'package:infolocate/screens/dashboard/controller/dashboard_provider.dart';
import 'package:infolocate/screens/dashboard/controller/sequel_dashboard_provider.dart';
import 'package:infolocate/screens/dynamic_status/controller/dyanmic_status_provider.dart';
import 'package:infolocate/screens/forgot_password/controller/forgot_password_provider.dart';
import 'package:infolocate/screens/splash/view/splash_view.dart';
import 'package:infolocate/screens/theme/controller/theme_provider.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/controller/vehicle_status_provider.dart';
import 'package:infolocate/screens/video_playback/controller/video_playback_provider.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'screens/login/controller/user_provider.dart';
import 'screens/pin_vehicles/controller/pin_vehicle_provider.dart';

/// Global navigator key for showing dialogs/toasts outside widget tree context.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Root widget: registers all [ChangeNotifierProvider]s, theme, localization, routes.
///
/// [initialRoute] is [SplashScreen] which decides the next screen from Hive session.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation,
          DeviceType deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => LanguageProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ClientLoginProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => UserProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ThemeProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => DashboardProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => SequelDashboardProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => AlertProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => VehicleStatusProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => DynamicStatusProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => VideoPlayBackProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => PinVehicleProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => CardTypeProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ForgotPasswordProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => AdsProvider(),
            ),
          ],
          child: AdaptiveTheme(
            builder: (ThemeData light, ThemeData dark) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                builder: (context, child) => Directionality(
                  textDirection: material.TextDirection.ltr,
                  child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child!),
                ),
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                debugShowCheckedModeBanner: false,
                title: 'InfoLocate',
                darkTheme: dark,
                theme: light,
                initialRoute: SplashScreen.routeName,
                routes: AppRoutes.routes(),
              );
            },
            initial: Global.savedThemeMode ?? AdaptiveThemeMode.light,
            light: AppStyles.appLightTheme(
                primaryColor: Global.savedPrimeryColor, ctx: context),
            dark: AppStyles.appDarkTheme(
                primaryColor: Global.savedPrimeryColor, ctx: context),
          ),
        );
      },
    );
  }
}
