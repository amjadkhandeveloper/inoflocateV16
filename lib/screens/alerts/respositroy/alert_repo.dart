import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/screens/alerts/model/alert_list_request_model.dart';
import 'package:infolocate/utils/app_globals.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_helper.dart';
import '../model/alert_list_response_model.dart';

/// Alert list API.
///
/// Endpoint: `{clientUrl}` + [alertwiseList] (POST).
class AlertService {
  var dio = Dio();

  Future<AlertListResponseModelData?> alertListService({required AlertListRequestModel? alertListRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'AlertService.alertListService');
      log(alertListRequestModel!.toJson().toString());
      //for testing shimmer
      // await Future.delayed(const Duration(seconds: 8));
      final response =
          await dio.post(Global.savedClientAuthData!.clientUrl! + alertwiseList, data: alertListRequestModel.toJson());
      print("Url ${Global.savedClientAuthData!.clientUrl! + alertwiseList}");
      print('Alert Screen: Req: ${alertListRequestModel.toJson()} Resp ${jsonEncode(response.data)}');
      // log(response.data);
      if (response.statusCode == 200) {
        return AlertListResponseModel.fromJson(response.data).data!;
      }
      return AlertListResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(AlertListResponseModel.fromJson(e.response!.data)
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
