import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/screens/alerts/model/alert_list_request_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/alert_list_response_model.dart';

/// Alert list API.
///
/// Common: `{clientUrl}` + [alertwiseList].
/// Sequel: [sequelAlertwiseListUrl] with swagger camelCase body.
class AlertService {
  var dio = Dio();

  Future<AlertListResponseModelData?> alertListService(
      {required AlertListRequestModel? alertListRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'AlertService.alertListService');
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelAlertwiseListUrl
          : Global.savedClientAuthData!.clientUrl! + app_const.alertwiseList;
      final body = isSequel
          ? alertListRequestModel!.toSequelJson()
          : alertListRequestModel!.toJson();
      final response = await dio.post(url, data: body);
      AppHelper.logApiCall(
        tag: 'AlertService.alertListService',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return AlertListResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ).data;
      }
      return AlertListResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        AppHelper.logApiCall(
          tag: 'AlertService.alertListService',
          method: 'POST',
          url: Global.isSequelClient
              ? app_const.sequelAlertwiseListUrl
              : Global.savedClientAuthData!.clientUrl! + app_const.alertwiseList,
          request: alertListRequestModel?.toJson(),
          status: e.response?.statusCode,
          response: e.response?.data,
          error: e,
        );
        throw Failure(AlertListResponseModel.fromJson(
                Map<String, dynamic>.from(e.response!.data as Map))
            .data!
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
