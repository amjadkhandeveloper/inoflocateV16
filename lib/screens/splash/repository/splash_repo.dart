import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/screens/splash/model/force_update_response_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_helper.dart';
import '../../../common_models/failure_model.dart';
import '../model/force_update_request_model.dart';

/// Pre-login API: app version / mandatory update check.
///
/// Endpoint: [forceUpdateUrl] (POST).
/// Called from [SplashScreen] when [Global.savedClientAuthData] is present.
class SplashService {
  var dio = Dio();

  // Future<ForceUpdateResponseModel?> forceUpdateService(
  //     {required ForceUpdateRequestModel forceUpdateRequestModel}) async {
  //   try {
  //     ForceUpdateResponseModel forceUpdateResponseModel;
  //     (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
  //         AppHelper().onHttpClientCreate;
  //     final response = await dio.post(app_const.forceUpdateUrl,
  //         data: forceUpdateRequestModel.toJson());
  //     if (response.statusCode == 200) {
  //       forceUpdateResponseModel =
  //           ForceUpdateResponseModel.fromJson(response.data);
  //       return forceUpdateResponseModel;
  //     }
  //   } on DioError catch (e) {
  //     if (e.error is SocketException) {
  //       throw Failure(LocaliazationKey.no_internet_connection.tr());
  //     } else if (e.error is HttpException) {
  //       throw Failure(LocaliazationKey.could_not_login.tr());
  //     } else if (e.error is FormatException) {
  //       throw Failure(LocaliazationKey.bad_response_format.tr());
  //     } else {
  //       log(e.error.toString());
  //       throw Failure(e.error.toString());
  //     }
  //   } catch (error) {
  //     log(error.toString());
  //     throw Failure(error.toString());
  //   }
  // }
  /// POST force-update payload; returns client update flags or throws [Failure].
  Future<ForceUpdateModelData?> forceUpdateService(
      {required ForceUpdateRequestModel forceUpdateRequestModel}) async {
    try {
      ForceUpdateModelData forceUpdateResponseModel;
      AppHelper.configureDio(dio, tag: 'SplashService.forceUpdateService');
      final response = await dio.post(app_const.forceUpdateUrl,
          data: forceUpdateRequestModel.toJson());
      print(response.data);
      if (response.statusCode == 200) {
        forceUpdateResponseModel = ForceUpdateModelData.fromJson(response.data);
        return forceUpdateResponseModel;
      }
      return ForceUpdateModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response);
        throw Failure(ForceUpdateModelData.fromJson(e.response!.data)
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
