import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/screens/splash/model/force_update_request_model.dart';
import 'package:infolocate/screens/splash/repository/splash_repo.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:infolocate/utils/app_ui.dart';

import '../../../widgets/dialog_box/force_update_dialog.dart';
import '../../language/view/select_language_screen.dart';

/// First screen after launch. Checks force-update, then routes by saved Hive session.
///
/// Navigation priority (see [navigateTo]):
/// 1. User logged in → Dashboard (common or Sequel)
/// 2. Client logged in only → User login
/// 3. Language saved → Client login
/// 4. Otherwise → Language selection
class SplashScreen extends StatefulWidget {
  static String routeName = '/';
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Long enough for the brand to paint, short enough that launch is not a wait.
  static const Duration _brandHold = Duration(milliseconds: 400);

  /// Force-update must not hold the splash if the server is slow.
  /// The dashboard runs the same check again after navigation.
  static const Duration _forceUpdateBudget = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_brandHold, _leaveSplash);
  }

  Future<void> _leaveSplash() async {
    if (!mounted) return;
    if (Global.savedClientAuthData != null && !Global.isSequelClient) {
      log('inside force update');
      await forceUpdate();
    }
    navigateTo();
  }

  /// Calls [SplashService.forceUpdateService] when a client session exists.
  Future<void> forceUpdate() async {
    final forceUpdateRequestModel = ForceUpdateRequestModel(
        clientId: Global.savedClientAuthData!.clientId,
        appversion: kAppVersion,
        appId: 1);
    try {
      final result = await SplashService()
          .forceUpdateService(forceUpdateRequestModel: forceUpdateRequestModel)
          .timeout(_forceUpdateBudget);

      if (!mounted || result?.client == null) return;
      await forceUpdateDialog(
          context: context, isMandatory: result!.client!.forceupdate == 1);
    } catch (e) {
      log('force update skipped: $e');
    }
  }

  /// Decides next route from [Global] Hive-backed session flags.
  navigateTo() {
    if (!mounted) return;
    if (Global.savedUserAuthData != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.dashboardRoute(), (route) => false);
      return;
    }
    if (Global.savedClientAuthData != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, UserLoginScreen.routeName, (route) => false);
      return;
    }
    if (Global.savedLanguageCode != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, ClientLoginScreen.routeName, (route) => false);
      return;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SelectLanguageScreen(
            inDrawer: false,
          ),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppUi.logoAsset,
              fit: BoxFit.contain,
              height: 120,
              cacheHeight: 240,
              errorBuilder: (_, __, ___) => AppUi.brandMark(size: 88),
            ),
            const SizedBox(height: 28),
            Text('InfoLocate', style: AppUi.brandTitle(context)),
            const SizedBox(height: 8),
            Text('Fleet tracking', style: AppUi.subtitle(context)),
            const SizedBox(height: 28),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppUi.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
