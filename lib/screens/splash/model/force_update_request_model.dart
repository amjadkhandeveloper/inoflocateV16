// To parse this JSON data, do
//
//     final forceUpdateRequestModel = forceUpdateRequestModelFromJson(jsonString);

import 'dart:convert';

ForceUpdateRequestModel forceUpdateRequestModelFromJson(String str) =>
    ForceUpdateRequestModel.fromJson(json.decode(str));

String forceUpdateRequestModelToJson(ForceUpdateRequestModel data) =>
    json.encode(data.toJson());

class ForceUpdateRequestModel {
  ForceUpdateRequestModel({
    required this.clientId,
    required this.appversion,
    required this.appId,
  });

  int? clientId;
  int? appversion;
  int? appId;

  factory ForceUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      ForceUpdateRequestModel(
        clientId: json["ClientId"],
        appversion: json["Appversion"],
        appId: json["AppId"],
      );

  Map<String, dynamic> toJson() => {
        "ClientId": clientId,
        "Appversion": appversion,
        "AppId": appId,
      };
}
