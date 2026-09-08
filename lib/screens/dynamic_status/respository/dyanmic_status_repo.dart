import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/screens/dynamic_status/model/dynamic_status_response_model.dart';
import 'package:infolocate/utils/app_globals.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_helper.dart';
import '../model/dynamic_status_request_model.dart';

/// Dynamic (live) vehicle list API.
///
/// Endpoint: `{clientUrl}` + [currDashVehicle] (POST).
/// Response: `vehicledetails` array + `vehicleCnt.reccount` for pagination.
class DynamicStatusService {
  var dio = Dio();

  /// POST [DynamicStatusRequestModel]; parses [DynamicStatusModel] from JSON `data` wrapper.
  Future<DynamicStatusModel?> dynamicStatusListService(
      {required DynamicStatusRequestModel? dynamicListRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'DynamicStatusService.dynamicStatusListService');
      final url = Global.savedClientAuthData!.clientUrl! + currDashVehicle;
      final body = dynamicListRequestModel!.toJson();
      final response = await dio.post(url, data: body);
      AppHelper.logApiCall(
        tag: 'DynamicStatusService.dynamicStatusListService',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );
      if (response.statusCode == 200) {
        return DynamicStatusModel.fromJson(response.data);
      }
      return DynamicStatusModel();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(DynamicStatusModel.fromJson(e.response!.data)
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
