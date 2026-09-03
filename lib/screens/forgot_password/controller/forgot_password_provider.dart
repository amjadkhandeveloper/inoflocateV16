import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infolocate/screens/forgot_password/repository/forgot_password_repo.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/enums.dart';
import '../model/forgot_password_request_model.dart';
import '../model/forgot_password_response_model.dart';

/// Forgot-password flow: emails reset link via [ForgotPasswordService].
class ForgotPasswordProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  ForgotPasswordResponseModel? _forgotPasswordResponseModel;

  NotifierState get state => _state;

  Failure get failure => _failure!;

  ForgotPasswordResponseModel? get forgotPasswordResponseModel =>
      _forgotPasswordResponseModel;

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
    _forgotPasswordResponseModel = null;
    customToast(message: failure.message.toString(), color: Colors.red);
    _failure = failure;
    notifyListeners();
  }

  forgotPassword(
      {required ForgotPasswordRequestModel forgotPasswordRequestModel}) async {
    setState(NotifierState.loading);
    try {
      final result = await ForgotPasswordService().forgotPasswordService(
          forgotPasswordRequestModel: forgotPasswordRequestModel);
      print(jsonEncode(result));
      _forgotPasswordResponseModel = result;
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
  }
}
