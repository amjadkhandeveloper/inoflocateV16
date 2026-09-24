import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/screens/fcm/model/fcm_token_request_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_helper.dart';

import '../../../common_models/failure_model.dart';

/// Sequel FCM token API: [sequelFcmRegisterTokenUrl].
class FcmTokenService {
  final dio = Dio();

  Future<void> registerToken({
    required FcmTokenRequestModel request,
  }) async {
    final url = app_const.sequelFcmRegisterTokenUrl;
    final body = request.toJson();
    try {
      AppHelper.configureDio(dio, tag: 'FcmTokenService.registerToken');
      final response = await dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      AppHelper.logApiCall(
        tag: 'FcmTokenService.registerToken',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );
    } on DioException catch (e) {
      AppHelper.logApiCall(
        tag: 'FcmTokenService.registerToken',
        method: 'POST',
        url: url,
        request: body,
        status: e.response?.statusCode,
        response: e.response?.data,
        error: e,
      );
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log(error.toString());
      throw Failure(error.toString());
    }
  }
}
