import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';

Future<dynamic> logoutAlertDialog(BuildContext context) async {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return CustomFadeScaleTransition(
          duration: const Duration(milliseconds: 400),
          child: AlertDialog(
            title: Text(LocaliazationKey.are_you_sure.tr()),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  LocaliazationKey.yes.tr(),
                  style: AppStyles.textStyle4(context: context),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  LocaliazationKey.no.tr(),
                  style: AppStyles.textStyle4(context: context),
                ),
              ),
            ],
          ),
        );
      });
}
