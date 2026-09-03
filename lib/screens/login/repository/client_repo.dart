import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infolocate/screens/login/model/client_model.dart';
import 'package:infolocate/utils/app_constants.dart' as app_const;
import 'package:infolocate/utils/app_encryption.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import '../../../common_models/failure_model.dart';
import '../model/user_login_request_model.dart';

/// Client (tenant) authentication API.
///
/// Endpoint: [authClient] (`POST .../URLAuthorization`).
/// Request fields are AES-encrypted `ClientName` / `Password`.
/// On success returns [ClientModelData] including per-tenant [clientUrl].
class ClientService {
  var dio = Dio();

  /// Validates client credentials; maps API auth errors to localized [Failure].
  Future<ClientModelData?> clientLoginService(
      {required UserLoginRequestModel loginRequestdata}) async {
    try {
      AppHelper.configureDio(dio, tag: 'ClientService.clientLoginService');
      final payload = {
        'ClientName':
            AppEncryption.encryptData(loginRequestdata.loginName ?? ''),
        'Password': AppEncryption.encryptData(loginRequestdata.loginPwd ?? ''),
      };
      print("Url ${app_const.authClient}");
      final response = await dio.post(app_const.authClient,
          data: payload,
          options: Options(contentType: Headers.jsonContentType));
      log(response.data.toString());

      print("Login Response: $response");

      if (response.statusCode == 200 && response.data is Map) {
        return _parseEncryptedClientResponse(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return ClientModelData();
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.statusCode != null &&
          e.response!.statusCode! > 200 &&
          e.response!.statusCode! < 404 &&
          e.response!.data != null) {
        print(e.response!.data);
        throw Failure(LocaliazationKey.could_not_login.tr());
      }
      throw await AppHelper.failureFromErrorAsync(e);
    } catch (error) {
      log('********');
      log(error.toString());
      throw await AppHelper.failureFromErrorAsync(error);
    }
  }

  ClientModelData _parseEncryptedClientResponse(Map<String, dynamic> json) {
    final status = (AppEncryption.decryptData(json['status']?.toString()) ?? '')
        .toLowerCase();
    var message = AppEncryption.decryptData(json['message']?.toString()) ?? '';

    if (status == 'failure') {
      if (message.toLowerCase().contains('invalid') ||
          message.toLowerCase().contains('authentication failed')) {
        message = LocaliazationKey.invalid_credetials.tr();
      }
      throw Failure(
        message.isEmpty ? LocaliazationKey.invalid_credetials.tr() : message,
      );
    }

    var url = AppEncryption.decryptData(json['url']?.toString()) ?? '';
    if (url.isEmpty || url.toUpperCase() == 'NA') {
      throw Failure(LocaliazationKey.could_not_login.tr());
    }
    if (!url.endsWith('/')) {
      url = '$url/';
    }

    return ClientModelData(
      status: 200,
      client: ClientModelDataClient(
        clientId: 0,
        clientUrl: url,
        currentVersion: 0,
      ),
    );
  }
}
