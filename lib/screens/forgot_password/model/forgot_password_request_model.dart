import 'dart:convert';

import '../../../utils/json_safe_parser.dart';

ForgotPasswordRequestModel forgotPasswordRequestModelFromJson(String str) =>
    ForgotPasswordRequestModel.fromJson(json.decode(str));

String forgotPasswordRequestModelToJson(ForgotPasswordRequestModel data) =>
    json.encode(data.toJson());

class ForgotPasswordRequestModel {
  String loginName;

  ForgotPasswordRequestModel({
    required this.loginName,
  });

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordRequestModel(
        loginName: JsonSafe.asString(json["LoginName"]),
      );

  Map<String, dynamic> toJson() => {
        "LoginName": loginName,
      };

  Map<String, dynamic> toSequelVerifyJson() => {
        "loginName": loginName,
        "loginPwd": "",
      };
}

class ResetPasswordRequestModel {
  int userid;
  String newPassword;

  ResetPasswordRequestModel({
    required this.userid,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        "userid": userid,
        "newPassword": newPassword,
      };
}
