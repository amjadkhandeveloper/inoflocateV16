import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/login/repository/user_repo.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/enums.dart';
import '../model/user_login_request_model.dart';
import '../model/user_login_response_model.dart';

/// User login screen state: calls [UserService], validates client id, saves user to Hive.
class UserProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  UserLoginResponseModel? _authData;

  NotifierState get state => _state;

  Failure get failure => _failure!;

  UserLoginResponseModel? get authData => _authData;

  loadingFalse() {
    setState(NotifierState.loaded);
    notifyListeners();
  }

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _authData = null;
    customToast(message: failure.message.toString(), color: Colors.red);
    _failure = failure;
    notifyListeners();
  }

  /// POST user credentials to tenant URL; saves [userAuthBoxKey] when client id matches.
  userLogin({required UserLoginRequestModel loginRequestdata}) async {
    setState(NotifierState.loading);
    try {
      final result = await UserService()
          .userLoginService(userLoginRequestModel: loginRequestdata);
      // print(jsonEncode(result));
      _authData = result;
      final user = result?.data?.user;
      if (user != null) {
        print("Global ${Global.savedClientAuthData?.clientId} and ${user.clientid}");
        final savedClient = Global.savedClientAuthData;
        final skipClientCheck = Global.isSequelClient ||
            savedClient?.clientId == null ||
            savedClient?.clientId == 0;
        if (!skipClientCheck && savedClient!.clientId != user.clientid) {
          _authData = null;
          customToast(
            message: LocaliazationKey.user_does_not_exist_for_this_client.tr(),
          );
        } else {
          print("Saving user data: ${user.toJson()}");
          await Global.box.put(userAuthBoxKey, user);
          await Global.box.put(userAdvertisement, user.showAdvertise);
          if (Global.isSequelClient &&
              savedClient != null &&
              user.clientid != null) {
            savedClient.clientId = user.clientid;
            await Global.box.put(clientAuthBoxKey, savedClient);
          }
        }
      }
      await AppHelper.getHiveBoxData();
    } on Failure catch (failure) {
      setFailure(failure);
    } catch (err) {
      setFailure(Failure(err.toString()));
    }
    setState(NotifierState.loaded);
  }
}
