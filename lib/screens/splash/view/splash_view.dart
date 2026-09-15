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
import 'package:sizer/sizer.dart';

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
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5000), () async {
      if (Global.savedClientAuthData != null && !Global.isSequelClient) {
        log('inside force update');
        await forceUpdate();
      }
      navigateTo();
    });
  }

  /// Calls [SplashService.forceUpdateService] when a client session exists.
  forceUpdate() async {
    ForceUpdateRequestModel forceUpdateRequestModel = ForceUpdateRequestModel(
        clientId: Global.savedClientAuthData!.clientId,
        appversion: kAppVersion,
        appId: 1);
    try {
      final result = await SplashService()
          .forceUpdateService(forceUpdateRequestModel: forceUpdateRequestModel);

      if (result!.client != null) {
        // ignore: use_build_context_synchronously
        await forceUpdateDialog(
            context: context, isMandatory: result.client!.forceupdate == 1);
        navigateTo();
      }
    } catch (e) {
      print(e);
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
              'assets/animation/splash_animation.gif',
              fit: BoxFit.contain,
              height: 28.h,
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
