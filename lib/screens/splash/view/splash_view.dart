import 'dart:async';
import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/login/view/client_login_view.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/screens/splash/model/force_update_request_model.dart';
import 'package:infolocate/screens/splash/repository/splash_repo.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_styles.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5000), () async {
      // navigateTo();
      if (Global.savedClientAuthData != null) {
        log('inside force update');
        await forceUpdate();
      }
      // log('outside');
      navigateTo();
    });
  }

  /// Calls [SplashService.forceUpdateService] when a client session exists.
  forceUpdate() async {
    ForceUpdateRequestModel forceUpdateRequestModel = ForceUpdateRequestModel(
        clientId: Global.savedClientAuthData!.clientId,
        appversion: 0,
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

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SvgPicture.asset('assets/images/splash_logo.svg'),
          Image.asset(
            'assets/animation/splash_animation.gif',
            fit: BoxFit.contain,
            height: 30.h,
          ),
          //added my comment
          SizedBox(
            height: 4.h,
          ),

          //this is comment from ruhaan
          AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
            // TypewriterAnimatedText(
            //   'InfoLocate',
            //   speed: const Duration(milliseconds: 100),
            //   textStyle: AppStyles.infoLocateTextStyle(context: context),
            // ),
            // WavyAnimatedText(
            //   'InfoLocate',
            //   speed: const Duration(milliseconds: 200),
            //   textStyle: AppStyles.infoLocateTextStyle(context: context),
            // ),
            ColorizeAnimatedText(
              'InfoLocate V14',
              textStyle: AppStyles.infoLocateTextStyle(context: context),
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.2)
              ],
            ),
          ])
          // Text(
          //   'InfoLocate',
          //   style: AppStyles.infoLocateTextStyle(context: context),
          // )
        ],
      )),
    );
  }
}
