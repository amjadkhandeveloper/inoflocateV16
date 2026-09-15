import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/screens/splash/model/force_update_response_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import '../../../common_models/failure_model.dart';
import '../model/force_update_request_model.dart';

/// Force-update API: Sequel [sequelForceUpdateUrl], others [forceUpdateUrl].
class SplashService {
  var dio = Dio();

  /// POST force-update payload; returns client update flags or throws [Failure].
  Future<ForceUpdateModelData?> forceUpdateService(
      {required ForceUpdateRequestModel forceUpdateRequestModel}) async {
    try {
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelForceUpdateUrl
          : app_const.forceUpdateUrl;
      final body = isSequel
          ? forceUpdateRequestModel.toSequelJson()
          : forceUpdateRequestModel.toJson();
      AppHelper.configureDio(dio, tag: 'SplashService.forceUpdateService');
      final response = await dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      AppHelper.logApiCall(
        tag: 'SplashService.forceUpdateService',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return ForceUpdateModelData.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return ForceUpdateModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response);
        throw Failure(ForceUpdateModelData.fromJson(
                Map<String, dynamic>.from(e.response!.data as Map))
            .error!
            .first!
            .message
            .toString());
      }
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log(error.toString());
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }
}
