// To parse this JSON data, do
//
//     final userLoginRequestModel = userLoginRequestModelFromJson(jsonString);

import 'dart:convert';

UserLoginRequestModel userLoginRequestModelFromJson(String str) =>
    UserLoginRequestModel.fromJson(json.decode(str));

String userLoginRequestModelToJson(UserLoginRequestModel data) =>
    json.encode(data.toJson());

/// Login credentials shared by client and user login screens.
///
/// Client login: [url] omitted — uses fixed [authClient] (`URLAuthorization`).
/// User login: [url] must be [Global.savedClientAuthData.clientUrl].
class UserLoginRequestModel {
  UserLoginRequestModel({
    required this.loginName,
    required this.loginPwd,
    this.url

  });

  String? loginName;
  String? loginPwd;
  String? url;

  factory UserLoginRequestModel.fromJson(Map<String, dynamic> json) =>
      UserLoginRequestModel(
        loginName: json["LoginName"],
        loginPwd: json["LoginPwd"],
      );

  Map<String, dynamic> toJson() => {
        "LoginName": loginName,
        "LoginPwd": loginPwd,
      };
}
