import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/screens/dashboard/model/dashboard_request_model.dart';
import 'package:infolocate/screens/dashboard/model/sequel_dashboard_response_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';

import '../../../common_models/failure_model.dart';

/// Sequel dashboard API: POST `{clientUrl}` + [sequelDashDataUrl].
class SequelDashboardService {
  final dio = Dio();

  Future<SequelDashboardResponse> getDashData({
    required DashboardRequestModel request,
  }) async {
    try {
      AppHelper.configureDio(dio, tag: 'SequelDashboardService.getDashData');
      final url = Global.joinClientUrl(app_const.sequelDashDataUrl);
      final body = {
        'userId': request.userId,
        'pSize': request.pSize,
        'pNo': request.pNo,
      };
      log('Sequel GetDashData $url $body');
      final response = await dio.post(
        url,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      AppHelper.logApiCall(
        tag: 'SequelDashboardService.getDashData',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final parsed = SequelDashboardResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        if (!parsed.isSuccess) {
          throw Failure(
            parsed.message?.isNotEmpty == true
                ? parsed.message
                : 'Dashboard data could not be loaded',
          );
        }
        return parsed;
      }
      throw Failure('Dashboard data could not be loaded');
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }
}
