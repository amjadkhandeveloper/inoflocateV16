import 'dart:convert';

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
        loginName: json["LoginName"],
      );

  Map<String, dynamic> toJson() => {
        "LoginName": loginName,
      };
}
