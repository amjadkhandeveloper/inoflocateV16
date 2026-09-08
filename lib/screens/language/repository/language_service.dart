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
        print(e.response!.data);
        throw Failure(GetCountriesResponseModel.fromJson(e.response!.data)
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

  /// Fetches languages available for the selected [countryId].
  /// Uses [getLanguageListUrl] — errors are mapped via [AppHelper.failureFromError].
  Future<LanguageResponseModelData?> getLanguageList(
      {required int? countryId}) async {
    try {
      AppHelper.configureDio(dio, tag: 'LanguageService.getLanguageList');
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
        print(e.response!.data);
        throw Failure(LanguageResponseModel.fromJson(e.response!.data)
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
