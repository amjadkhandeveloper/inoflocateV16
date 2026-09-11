import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/pin_vehicle_request_model.dart';
import '../model/pin_vehicle_response_model.dart';

/// Pinned vehicles API (list / pin / unpin).
///
/// Common: `{clientUrl}` + [pinVehicle].
/// Sequel: [sequelPinVehicleUrl] (`insertMode` 0 = pin, 1 = unpin).
class PinVehicleService {
  var dio = Dio();

  Future<PinVehicleResponseModelData?> pinUnpinVehicle(
      {required PinVehicleRequestModel pinVehicleRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'PinVehicleService.pinUnpinVehicle');
      final isSequel = Global.isSequelClient;
      final url = isSequel
          ? app_const.sequelPinVehicleUrl
          : Global.savedClientAuthData!.clientUrl! + app_const.pinVehicle;
      final body = isSequel
          ? pinVehicleRequestModel.toSequelJson()
          : pinVehicleRequestModel.toJson();
      final response = await dio.post(
          url,
          data: body,
          options: Options(contentType: Headers.jsonContentType));
      AppHelper.logApiCall(
        tag: 'PinVehicleService.pinUnpinVehicle',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return PinVehicleResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        ).data;
      }
      return PinVehicleResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(PinVehicleResponseModel.fromJson(e.response!.data)
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
