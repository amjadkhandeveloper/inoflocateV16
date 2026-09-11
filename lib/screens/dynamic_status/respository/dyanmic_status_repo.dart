import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/screens/dynamic_status/model/dynamic_status_response_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/dynamic_status_request_model.dart';

/// Dynamic (live) vehicle list API.
///
/// Common: `{clientUrl}` + [currDashVehicle].
/// Sequel: [sequelCurrDashVehicleUrl] with swagger camelCase body.
class DynamicStatusService {
  var dio = Dio();

  Future<DynamicStatusModel?> dynamicStatusListService(
      {required DynamicStatusRequestModel? dynamicListRequestModel}) async {
    try {
      AppHelper.configureDio(
          dio, tag: 'DynamicStatusService.dynamicStatusListService');
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelCurrDashVehicleUrl
          : Global.savedClientAuthData!.clientUrl! + app_const.currDashVehicle;
      final body = isSequel
          ? dynamicListRequestModel!.toSequelJson()
          : dynamicListRequestModel!.toJson();
      final response = await dio.post(url, data: body);
      AppHelper.logApiCall(
        tag: 'DynamicStatusService.dynamicStatusListService',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return DynamicStatusModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return DynamicStatusModel();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(DynamicStatusModel.fromJson(
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
