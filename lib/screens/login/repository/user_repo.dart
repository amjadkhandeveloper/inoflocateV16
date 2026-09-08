import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
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
      AppHelper.logApiCall(
        tag: 'UserService.userLoginService',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200) {
        final map = _asJsonMap(response.data);
        if (map == null) {
          throw Failure(LocaliazationKey.could_not_login.tr());
        }
        final parsed = UserLoginResponseModel.fromJson(map);
        final status = parsed.data?.status ??
            _asInt(map['status']) ??
            _asInt(map['Status']);
        final message =
            (map['message'] ?? map['Message'])?.toString();
        final user = parsed.data?.user;
        final success = status == 1 || status == 200 || (user?.userid != null);
        if (!success || user == null) {
          throw Failure(
            (message != null &&
                    message.isNotEmpty &&
                    !message.toLowerCase().contains('success'))
                ? message
                : LocaliazationKey.could_not_login.tr(),
          );
        }
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
            message = raw['message']?.toString() ??
                UserLoginResponseModel.fromJson(
                  Map<String, dynamic>.from(raw),
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

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

Map<String, dynamic>? _asJsonMap(dynamic data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String) {
    final trimmed = data.trim();
    if (trimmed.startsWith('{')) {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
  }
  return null;
}
