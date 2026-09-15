import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/json_safe_parser.dart';
import '../model/user_login_request_model.dart';
import '../model/user_login_response_model.dart';

/// User authentication API (runs after client login).
///
/// Common: `{clientUrl}` + [authUser].
/// Sequel: [sequelUserLoginUrl] (`/api/Auth/UserLogin`).
class UserService {
  final dio = Dio();

  /// Logs in user; verifies [clientid] matches saved client in [UserProvider].
  Future<UserLoginResponseModel?> userLoginService({
    required UserLoginRequestModel userLoginRequestModel,
  }) async {
    try {
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelUserLoginUrl
          : '${userLoginRequestModel.url}${app_const.authUser}';
      final body = isSequel
          ? {
              'loginName': userLoginRequestModel.loginName,
              'loginPwd': userLoginRequestModel.loginPwd,
              'language': Global.savedLanguageCode ?? 'en',
              'theme': 1,
            }
          : userLoginRequestModel.toJson();

      AppHelper.configureDio(dio, tag: 'UserService.userLoginService');
      log('User login $url');
      final response = await dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      if (response.statusCode == 200) {
        final map = JsonSafe.asMapOrNull(response.data);
        if (map == null) {
          AppHelper.logApiCall(
            tag: 'UserService.userLoginService',
            method: 'POST',
            url: url,
            request: body,
            status: response.statusCode,
            response: response.data,
            error: 'Invalid login response body',
          );
          throw Failure(LocaliazationKey.could_not_login.tr());
        }
        final parsed = UserLoginResponseModel.fromJson(map);
        final nested = JsonSafe.asMapOrNull(map['data']);
        final status = JsonSafe.asIntOrNull(map['status'] ?? map['Status']) ??
            JsonSafe.asIntOrNull(nested?['status'] ?? nested?['Status']);
        final message = JsonSafe.asStringOrNull(
                map['message'] ?? map['Message'] ?? map['remark']) ??
            JsonSafe.asStringOrNull(
              nested?['message'] ?? nested?['Message'],
            );
        final user = parsed.data?.user;
        final userid = user?.userid ?? 0;
        final username = (user?.username ?? '').trim();
        final explicitFail = status == 0;
        final statusOk = status == 1 || status == 200 || status == null;
        final success =
            !explicitFail && statusOk && userid > 0 && username.isNotEmpty;
        if (!success || user == null) {
          final failureMessage = (message != null &&
                  message.isNotEmpty &&
                  !message.toLowerCase().contains('success'))
              ? (message.toLowerCase().contains('auth') ||
                      message.toLowerCase().contains('invalid') ||
                      message.toLowerCase().contains('fail')
                  ? LocaliazationKey.invalid_credetials.tr()
                  : message)
              : LocaliazationKey.invalid_credetials.tr();
          AppHelper.logApiCall(
            tag: 'UserService.userLoginService',
            method: 'POST',
            url: url,
            request: body,
            status: response.statusCode,
            response: response.data,
            error: failureMessage,
          );
          throw Failure(failureMessage);
        }
        AppHelper.logApiCall(
          tag: 'UserService.userLoginService',
          method: 'POST',
          url: url,
          request: body,
          status: response.statusCode,
          response: response.data,
        );
        return parsed;
      }
      throw Failure(LocaliazationKey.could_not_login.tr());
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! >= 400 &&
          e.response!.statusCode! < 500 &&
          e.response!.data != null) {
        try {
          final raw = e.response!.data;
          String? message;
          if (raw is Map) {
            message = JsonSafe.asStringOrNull(raw['message']) ??
                UserLoginResponseModel.fromJson(
                  JsonSafe.asMap(raw),
                ).data?.error?.first?.message?.toString();
          }
          message ??= LocaliazationKey.could_not_login.tr();
          if (message == "Authentication failed") {
            message = LocaliazationKey.invalid_credetials.tr();
          }
          throw Failure(message);
        } catch (err) {
          if (err is Failure) rethrow;
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
