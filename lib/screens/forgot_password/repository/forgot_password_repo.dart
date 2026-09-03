import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import '../../../common_models/failure_model.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../model/forgot_password_request_model.dart';
import '../model/forgot_password_response_model.dart';

/// Forgot-password / verify-user API.
///
/// Endpoint: `{clientUrl}` + [forgotPassword] (POST).
class ForgotPasswordService {
  final dio = Dio();
  Future<ForgotPasswordResponseModel?> forgotPasswordService({
    required ForgotPasswordRequestModel forgotPasswordRequestModel,
  }) async {
    try {
      ForgotPasswordResponseModel? forgotPasswordResponseModel;

      print(
          'Forgot Password request body--> ${forgotPasswordRequestModel.toJson()}');
      AppHelper.configureDio(dio, tag: 'ForgotPasswordService.forgotPasswordService');
      print(forgotPasswordRequestModel.toJson());

      final response = await dio.post(
          Global.savedClientAuthData!.clientUrl! + app_const.forgotPassword,
          data: forgotPasswordRequestModel.toJson());
      print(response.data);
      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        forgotPasswordResponseModel =
            ForgotPasswordResponseModel.fromJson(response.data);
        return forgotPasswordResponseModel;
      }
      return forgotPasswordResponseModel;
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response);
        var message = ForgotPasswordResponseModel.fromJson(e.response!.data)
            .data!
            .message
            .toString();
        var newMessage = "User doesn't exist";
        if (message == "User doesn't exist") {
          newMessage = LocaliazationKey.user_doesnt_exits.tr();
        } else {
          newMessage = message;
        }
        throw Failure(newMessage);
      }
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log(error.toString());
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }
}
