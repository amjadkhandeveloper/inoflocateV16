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
/// Endpoint: `{clientUrl}` + [pinVehicle] (POST).
class PinVehicleService {
  var dio = Dio();

  Future<PinVehicleResponseModelData?> pinUnpinVehicle(
      {required PinVehicleRequestModel pinVehicleRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'PinVehicleService.pinUnpinVehicle');
      final response = await dio.post(
          Global.savedClientAuthData!.clientUrl! + app_const.pinVehicle,
          data: pinVehicleRequestModel.toJson(),
          options: Options(contentType: Headers.jsonContentType));
      log(Global.savedClientAuthData!.clientUrl! + app_const.pinVehicle);
      log(pinVehicleRequestModel.toJson().toString());
      log(response.data.toString());

      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        return PinVehicleResponseModel.fromJson(response.data).data;
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
