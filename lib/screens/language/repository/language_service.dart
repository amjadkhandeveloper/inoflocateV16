import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:infolocate/screens/language/model/language_model.dart';
import 'package:infolocate/utils/app_constants.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_helper.dart';
import '../model/get_countries_response_model.dart';

/// Pre-login language/country APIs used by [SelectLanguageScreen].
class LanguageService {
  var dio = Dio();

  /// Fetches country list for the language selection screen.
  /// Uses [getCountryListUrl] — errors are mapped via [AppHelper.failureFromError].
  Future<GetCountriesResponseModelData?> getCountriesList() async {
    try {
      AppHelper.configureDio(dio, tag: 'LanguageService.getCountriesList');
      _useShortTimeout();
      final response = await dio.get(
        getCountryListUrl,
        options: Options(contentType: Headers.jsonContentType),
      );
      AppHelper.logApiCall(
        tag: 'LanguageService.getCountriesList',
        method: 'GET',
        url: getCountryListUrl,
        request: null,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200) {
        return GetCountriesResponseModel.fromJson(response.data).data;
      }
      return GetCountriesResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        AppHelper.logApiTrace('Language error body: ${e.response!.data}');
        throw Failure(GetCountriesResponseModel.fromJson(e.response!.data)
            .data!
            .error!
            .first!
            .message
            .toString());
      }
      throw Failure(e.message ?? 'Country list unavailable');
    } catch (error) {
      log(error.toString());
      if (error is Failure) rethrow;
      throw Failure(error.toString());
    }
  }

  /// The language screen falls back locally, so a dead host must not sit on the 15s API timeout.
  void _useShortTimeout() {
    dio.options.connectTimeout = const Duration(seconds: 8);
    dio.options.receiveTimeout = const Duration(seconds: 8);
    dio.options.sendTimeout = const Duration(seconds: 8);
  }

  /// Fetches languages available for the selected [countryId].
  /// Uses [getLanguageListUrl] — errors are mapped via [AppHelper.failureFromError].
  Future<LanguageResponseModelData?> getLanguageList(
      {required int? countryId}) async {
    try {
      AppHelper.configureDio(dio, tag: 'LanguageService.getLanguageList');
      _useShortTimeout();
      final body = {"CountryId": countryId};
      final response = await dio.post(
        getLanguageListUrl,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      AppHelper.logApiCall(
        tag: 'LanguageService.getLanguageList',
        method: 'POST',
        url: getLanguageListUrl,
        request: body,
        status: response.statusCode,
        response: response.data,
      );

      if (response.statusCode == 200) {
        return LanguageResponseModel.fromJson(response.data).data;
      }
      return LanguageResponseModelData();
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        AppHelper.logApiTrace('Language error body: ${e.response!.data}');
        throw Failure(LanguageResponseModel.fromJson(e.response!.data)
            .data!
            .error!
            .first!
            .message
            .toString());
      }
      throw Failure(e.message ?? 'Language list unavailable');
    } catch (error) {
      log(error.toString());
      if (error is Failure) rethrow;
      throw Failure(error.toString());
    }
  }
}
