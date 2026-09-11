import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/model/history_track_response_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/history_track_request_model.dart';
import '../model/vehicle_status_request_model.dart';
import '../model/vehicle_status_response_model.dart';

/// Vehicle status list and track history APIs.
///
/// Endpoints:
/// - `{clientUrl}` + [vehicleStatus] — status-wise vehicle list
/// - `{clientUrl}` + [historyTrackVehicle] — map track history
class VehicleStatusService {
  var dio = Dio();

  Future<VehicleStatusResponseModelData?> getVehicleList(
      {required VehicleStatusWiseListRequestModel
          vehicleStatusWiseListRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'VehicleStatusService.getVehicleList');
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelVehicleStatusUrl
          : Global.savedClientAuthData!.clientUrl! + app_const.vehicleStatus;
      final body = isSequel
          ? vehicleStatusWiseListRequestModel.toSequelJson()
          : vehicleStatusWiseListRequestModel.toJson();
      final response = await dio.post(
          url,
          data: body,
          options: Options(contentType: Headers.jsonContentType));
      AppHelper.logApiCall(
        tag: 'VehicleStatusService.getVehicleList',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      // final json = jsonDecode(.toString());

      if (response.statusCode == 200 && response.data is Map) {
        return VehicleStatusResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ).data;
      }
      return VehicleStatusResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(VehicleStatusResponseModel.fromJson(e.response!.data)
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

  Future<VehicleHistoryTrackModelData?> vehicleHistoryTrackApi(
      {required HistoryTrackRequestModel
          vehicleHistoryTrackRequestModel}) async {
    try {
      AppHelper.configureDio(
          dio, tag: 'VehicleStatusService.vehicleHistoryTrackApi');
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelHistoryTrackUrl
          : '${Global.savedClientAuthData!.clientUrl}${app_const.historyTrackVehicle}';
      final body = isSequel
          ? vehicleHistoryTrackRequestModel.toJson()
          : vehicleHistoryTrackRequestModel.toCommonJson();
      log('History track $url');
      log(jsonEncode(body));
      final response = await dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      AppHelper.logApiCall(
        tag: 'VehicleStatusService.vehicleHistoryTrackApi',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final parsed = VehicleHistoryTrackModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        return parsed.data ?? VehicleHistoryTrackModelData();
      }
      return VehicleHistoryTrackModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure('Something went wrong!, please try later');
      }
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log(error.toString());
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }
}
