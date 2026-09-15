import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/forgot_password/repository/forgot_password_repo.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_localization_key.dart';
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
      if (result == null || result.isSuccess != true) {
        throw Failure(
          (result?.data?.message ?? '').trim().isNotEmpty
              ? result!.data!.message!
              : LocaliazationKey.could_not_login.tr(),
        );
      }
      _forgotPasswordResponseModel = result;
      setState(NotifierState.loaded);
    } on Failure catch (failure) {
      setFailure(failure);
      setState(NotifierState.loaded);
    } catch (_) {
      setState(NotifierState.loaded);
      rethrow;
    }
  }

  Future<bool> resetPassword({
    required ResetPasswordRequestModel resetPasswordRequestModel,
  }) async {
    setState(NotifierState.loading);
    try {
      final result = await ForgotPasswordService().resetPasswordService(
          resetPasswordRequestModel: resetPasswordRequestModel);
      _forgotPasswordResponseModel = result;
      setState(NotifierState.loaded);
      return result?.isSuccess == true;
    } on Failure catch (failure) {
      setFailure(failure);
      setState(NotifierState.loaded);
      return false;
    }
  }
}
