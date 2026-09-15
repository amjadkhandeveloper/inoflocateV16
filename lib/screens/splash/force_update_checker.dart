import 'package:flutter/material.dart';
import 'package:infolocate/screens/splash/model/force_update_request_model.dart';
import 'package:infolocate/screens/splash/repository/splash_repo.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/widgets/dialog_box/force_update_dialog.dart';

/// Dashboard force-update check. Sequel uses [sequelForceUpdateUrl].
class ForceUpdateChecker {
  static bool _dialogShown = false;

  static Future<void> checkFromDashboard(BuildContext context) async {
    if (_dialogShown || !context.mounted) return;
    final clientId = Global.savedUserAuthData?.clientid ??
        Global.savedClientAuthData?.clientId;
    if (clientId == null || clientId <= 0) return;
    try {
      final result = await SplashService().forceUpdateService(
        forceUpdateRequestModel: ForceUpdateRequestModel(
          clientId: clientId,
          appversion: kAppVersion,
          appId: 1,
        ),
      );
      final force = result?.client?.forceupdate ?? 0;
      if (force != 1 || !context.mounted) return;
      _dialogShown = true;
      await forceUpdateDialog(context: context, isMandatory: true);
    } catch (_) {
      // Dashboard load should not fail if the update check errors.
    }
  }
}
