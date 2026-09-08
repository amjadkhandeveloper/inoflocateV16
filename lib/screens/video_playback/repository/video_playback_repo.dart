import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import '../../../common_models/failure_model.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../model/video_playback_request_model.dart';
import '../model/video_playback_response_model.dart';
import '../model/video_vehicle_list_response_model.dart';

/// Video playback vehicle list and playback URL APIs.
///
/// Endpoints:
/// - `{clientUrl}` + [videoVehicleList]
/// - `{clientUrl}` + [vehicleVideoPlayback]
class VideoPlayBackService {
  final dio = Dio();
  Future<VideoVehicleListData?> getVehicleList({required int userId}) async {
    try {
      AppHelper.configureDio(dio, tag: 'VideoPlayBackService.getVehicleList');
      final url =
          Global.savedClientAuthData!.clientUrl! + app_const.videoVehicleList;
      Map<String, dynamic> data = {
        "UserId": userId,
      };
      final response = await dio.post(
          url,
          data: data,
          options: Options(contentType: Headers.jsonContentType));
      AppHelper.logApiCall(
        tag: 'VideoPlayBackService.getVehicleList',
        method: 'POST',
        url: url,
        request: data,
        status: response.statusCode,
        response: response.data,
      );
      if (response.statusCode == 200) {
        return VideoVehicleList.fromJson(response.data).data;
      }
      return VideoVehicleListData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(VideoVehicleList.fromJson(e.response!.data)
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

  Future<VideoPlayBackResponseModelData?> generateVideoPlayback({
    required VideoPlayBackRequestModel videoPlayBackRequestModel,
  }) async {
    try {
      VideoPlayBackResponseModelData? videoPlayBackResponseModelData;

      print(
          'VideoPlayBack request body--> ${videoPlayBackRequestModel.toJson()}');
      AppHelper.configureDio(dio, tag: 'VideoPlayBackService.generateVideoPlayback');
      final url = Global.savedClientAuthData!.clientUrl! +
          app_const.vehicleVideoPlayback;
      final body = videoPlayBackRequestModel.toJson();
      final response = await dio.post(url, data: body);
      AppHelper.logApiCall(
        tag: 'VideoPlayBackService.generateVideoPlayback',
        method: 'POST',
        url: url,
        request: body,
        status: response.statusCode,
        response: response.data,
      );
      // final json = jsonDecode(.toString());

      if (response.statusCode == 200) {
        videoPlayBackResponseModelData =
            VideoPlayBackResponseModel.fromJson(response.data).data;
        return videoPlayBackResponseModelData;
      }
      return videoPlayBackResponseModelData;
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response);
        throw Failure(VideoPlayBackResponseModel.fromJson(e.response!.data)
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
