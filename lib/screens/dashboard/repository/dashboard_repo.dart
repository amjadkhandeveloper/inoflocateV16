import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/dashboard_request_model.dart';
import '../model/dashboard_response_model.dart';

/// Dashboard fleet summary API.
///
/// Endpoint: `{clientUrl}` + [dashboardUrl] (POST).
class DashboardService {
  var dio = Dio();

  /// Returns vehicle counts / chart data for [HomeScreen].
  Future<DashboardResponseModelData?> getDashboardData(
      {required DashboardRequestModel dashboardRequestModel}) async {
    try {
      AppHelper.configureDio(dio, tag: 'DashboardService.getDashboardData');
      final url =
          Global.savedClientAuthData!.clientUrl! + app_const.dashboardUrl;
      final body = dashboardRequestModel.toJson();
      final response = await dio.post(
          url,
          data: body,
          options: Options(contentType: Headers.jsonContentType));
      AppHelper.logApiCall(
        tag: 'DashboardService.getDashboardData',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        return DashboardResponseModel.fromJson(response.data).data;
      }
      return DashboardResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(DashboardResponseModel.fromJson(e.response!.data)
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
