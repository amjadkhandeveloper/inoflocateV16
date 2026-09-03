import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:url_launcher/url_launcher.dart';

Future<dynamic> forceUpdateDialog(
    {required BuildContext context, bool isMandatory = false}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: CustomFadeScaleTransition(
            duration: const Duration(milliseconds: 400),
            child: AlertDialog(
              title: Text(LocaliazationKey.update_available.tr()),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      try {
                        launchUrl(
                          Uri.parse(
                              "market://details?id=com.infotrack.threegohostcars"),
                          mode: LaunchMode.externalApplication,
                        );
                      } on PlatformException {
                        launchUrl(
                          Uri.parse(
                              "https://play.google.com/store/apps/details?id=com.infotrack.threegohostcars"),
                          mode: LaunchMode.externalApplication,
                        );
                      } finally {
                        launchUrl(
                          Uri.parse(
                              "https://play.google.com/store/apps/details?id=com.infotrack.threegohostcars"),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    } else {
                      //Change id of application : 1666816221 for RENTER
                      launchUrl(
                        Uri.parse("https://apps.apple.com/app/id1666816557"),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    LocaliazationKey.update.tr(),
                    style: AppStyles.textStyle4(context: context),
                  ),
                ),
                TextButton(
                  onPressed: isMandatory
                      ? () => exit(0)
                      : () => Navigator.pop(context),
                  child: Text(
                    LocaliazationKey.cancel.tr(),
                    style: AppStyles.textStyle4(context: context),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
