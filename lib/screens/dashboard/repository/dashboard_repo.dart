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
      log(Global.savedClientAuthData!.clientUrl! + app_const.dashboardUrl);
      log(jsonEncode(dashboardRequestModel));
      // For testing shimmer effect
      // await Future.delayed(const Duration(seconds: 8));
      final response = await dio.post(
          Global.savedClientAuthData!.clientUrl! + app_const.dashboardUrl,
          data: dashboardRequestModel.toJson(),
          options: Options(contentType: Headers.jsonContentType));
      log(response.data.toString());

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
