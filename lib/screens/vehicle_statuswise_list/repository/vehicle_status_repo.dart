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
      log(Global.savedClientAuthData!.clientUrl! + app_const.vehicleStatus);
      log(jsonEncode(vehicleStatusWiseListRequestModel));
      final response = await dio.post(
          Global.savedClientAuthData!.clientUrl! + app_const.vehicleStatus,
          data: vehicleStatusWiseListRequestModel.toJson(),
          options: Options(contentType: Headers.jsonContentType));
      log(response.data.toString());

      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        return VehicleStatusResponseModel.fromJson(response.data).data;
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
      AppHelper.configureDio(dio, tag: 'VehicleStatusService.vehicleHistoryTrackApi');
      log(Global.savedClientAuthData!.clientUrl! +
          app_const.historyTrackVehicle);
      log(jsonEncode(vehicleHistoryTrackRequestModel));
      final response = await dio.post(
          Global.savedClientAuthData!.clientUrl! +
              app_const.historyTrackVehicle,
          data: vehicleHistoryTrackRequestModel.toJson(),
          options: Options(contentType: Headers.jsonContentType));
      // log(response.data.toString());

      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        return VehicleHistoryTrackModel.fromJson(response.data).data;
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
