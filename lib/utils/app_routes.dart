import 'package:flutter/material.dart';
import 'package:infolocate/screens/dashboard/view/dashboard_view.dart';
import 'package:infolocate/screens/intro/view/intro_view.dart';
import 'package:infolocate/screens/language/view/select_language_screen.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/screens/splash/view/splash_view.dart';
import 'package:infolocate/screens/theme/view/theme_screen.dart';

import '../screens/alerts/view/alert_screen.dart';
import '../screens/dynamic_status/view/dynamic_status_screen.dart';
import '../screens/trips/view/trip_dashboard.dart';

/// Named-route table for [MaterialApp.routes].
///
/// Flow: Splash → Language → Client login → User login → [HomeScreen] (dashboard).
/// Drawer items (dynamic status, alerts, etc.) are also registered here.
class AppRoutes {
  /// Returns route name → screen builder map used by [MaterialApp].
  static Map<String, Widget Function(BuildContext)> routes() {
    return {
      SplashScreen.routeName: (_) => const SplashScreen(),
      IntroScreen.routeName: (_) => const IntroScreen(),
      SelectLanguageScreen.routeName: (_) => const SelectLanguageScreen(
            inDrawer: false,
          ),
      ClientLoginScreen.routeName: (_) => const ClientLoginScreen(),
      UserLoginScreen.routeName: (_) => const UserLoginScreen(),
      HomeScreen.routeName: (_) => const HomeScreen(),
      ThemeScreen.routeName: (_) => const ThemeScreen(),
      DynamicStatusScreen.routeName: (_) => const DynamicStatusScreen(),
      TripDashBoard.routeName: (_) => const TripDashBoard(),
      AlertDashboardScreen.routeName: (_) => const AlertDashboardScreen(),
    };
  }
}
