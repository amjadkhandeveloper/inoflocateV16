// To parse this JSON data, do
//
//     final vehicleStatusWiseListRequestModel = vehicleStatusWiseListRequestModelFromJson(jsonString);

import 'dart:convert';

VehicleStatusWiseListRequestModel vehicleStatusWiseListRequestModelFrxomJson(
        String str) =>
    VehicleStatusWiseListRequestModel.fromJson(json.decode(str));

String vehicleStatusWiseListRequestModelToJson(
        VehicleStatusWiseListRequestModel data) =>
    json.encode(data.toJson());

class VehicleStatusWiseListRequestModel {
  VehicleStatusWiseListRequestModel({
    required this.userId,
    required this.statusId,
    required this.pSize,
    required this.pNo,
    required this.sSearch,
  });

  int userId;
  int statusId;
  int pSize;
  int pNo;
  String sSearch;

  factory VehicleStatusWiseListRequestModel.fromJson(
          Map<String, dynamic> json) =>
      VehicleStatusWiseListRequestModel(
        userId: json["UserId"],
        statusId: json["StatusId"],
        pSize: json["pSize"],
        pNo: json["PNo"],
        sSearch: json["sSearch"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "StatusId": statusId,
        "pSize": pSize,
        "PNo": pNo,
        "sSearch": sSearch
      };
}
