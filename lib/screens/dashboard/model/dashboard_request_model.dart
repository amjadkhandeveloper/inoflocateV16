// To parse this JSON data, do
//
//     final dashboardRequestModel = dashboardRequestModelFromJson(jsonString);

import 'dart:convert';

DashboardRequestModel dashboardRequestModelFromJson(String str) =>
    DashboardRequestModel.fromJson(json.decode(str));

String dashboardRequestModelToJson(DashboardRequestModel data) =>
    json.encode(data.toJson());

class DashboardRequestModel {
  DashboardRequestModel({
    required this.userId,
    required this.pSize,
    required this.pNo,
  });

  int userId;
  int pSize;
  int pNo;

  factory DashboardRequestModel.fromJson(Map<String, dynamic> json) =>
      DashboardRequestModel(
        userId: json["UserId"],
        pSize: json["pSize"],
        pNo: json["PNo"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "pSize": pSize,
        "PNo": pNo,
      };
}
