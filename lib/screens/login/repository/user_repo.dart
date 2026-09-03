import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../model/user_login_request_model.dart';
import '../model/user_login_response_model.dart';

/// User authentication API (runs after client login).
///
/// Endpoint: `{clientUrl}` + [authUser] (POST).
/// [UserLoginRequestModel.url] must be [Global.savedClientAuthData.clientUrl].
class UserService {
  final dio = Dio();
  /// Logs in user; verifies [clientid] matches saved client in [UserProvider].
  Future<UserLoginResponseModel?> userLoginService({
    required UserLoginRequestModel userLoginRequestModel,
  }) async {
    try {
      UserLoginResponseModel? userLoginResponseModel;

      print('User login request body--> ${userLoginRequestModel.toJson()}');
      AppHelper.configureDio(dio, tag: 'UserService.userLoginService');
      print(userLoginRequestModel.toJson());
      log(userLoginRequestModel.url! + app_const.authUser);
      final response = await dio.post(
          userLoginRequestModel.url! + app_const.authUser,
          data: userLoginRequestModel.toJson());
      print(response.data);
      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        userLoginResponseModel = UserLoginResponseModel.fromJson(response.data);
        return userLoginResponseModel;
      }
      return userLoginResponseModel;
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! >= 400 &&
          e.response!.statusCode! < 500 &&
          e.response!.data != null) {
        try {
          var message = UserLoginResponseModel.fromJson(e.response!.data)
                  .data
                  ?.error
                  ?.first
                  ?.message
                  ?.toString() ??
              LocaliazationKey.could_not_login.tr();
          if (message == "Authentication failed") {
            message = LocaliazationKey.invalid_credetials.tr();
          }
          throw Failure(message);
        } catch (_) {
          throw await AppHelper.failureFromErrorAsync(e);
        }
      }
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log(error.toString());
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }
}
