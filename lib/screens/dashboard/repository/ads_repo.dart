import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/ads_response_model.dart';

/// Dashboard advertisements API.
///
/// Endpoint: `{clientUrl}` + [adsUrl] (POST, body: `clientId`).
class AdsService {
  var dio = Dio();

  Future<AdsResponseModelData?> getAds({required int clientId}) async {
    try {
      AppHelper.configureDio(dio, tag: 'AdsService.getAds');
      final url = Global.savedClientAuthData!.clientUrl! + app_const.adsUrl;
      final requestbody = {"clientId": clientId};
      final response = await dio.post(
          url,
          data: requestbody,
          options: Options(contentType: Headers.jsonContentType));
      AppHelper.logApiCall(
        tag: 'AdsService.getAds',
        method: 'POST',
        url: url,
        request: requestbody,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200) {
        return AdsResponseModel.fromJson(response.data).data;
      }
      return AdsResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(AdsResponseModel.fromJson(e.response!.data)
            .data!
            .error!
            .first!
            .message
            .toString());
      }
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log('********');
      log(error.toString());
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }
}
