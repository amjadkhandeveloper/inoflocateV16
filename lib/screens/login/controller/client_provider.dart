import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/enums.dart';
import '../../../widgets/custom_toast.dart';
import '../model/user_login_request_model.dart';
import '../repository/client_repo.dart';
import '../model/client_model.dart';
import '../../../utils/app_helper.dart';

/// Client login screen state: calls [ClientService], persists client to Hive.
class ClientLoginProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  ClientModelData? _authData;

  NotifierState get state => _state;

  Failure get failure => _failure!;

  ClientModelData? get authData => _authData;

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

  /// POST client credentials; on success saves [clientAuthBoxKey] and refreshes [Global].
  clientLogin({required UserLoginRequestModel loginRequestdata}) async {
    setState(NotifierState.loading);
    try {
      final result = await ClientService()
          .clientLoginService(loginRequestdata: loginRequestdata);
      print(jsonEncode(result));
      _authData = result;
      if (_authData != null) {
        await Global.box.put(clientAuthBoxKey, _authData!.client);
      }
      await AppHelper.getHiveBoxData();
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
  }
}
