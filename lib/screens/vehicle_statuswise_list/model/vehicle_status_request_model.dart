// To parse this JSON data, do
//
//     final vehicleStatusWiseListRequestModel = vehicleStatusWiseListRequestModelFromJson(jsonString);

import 'dart:convert';

import '../../../utils/json_safe_parser.dart';

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
        userId: JsonSafe.asInt(JsonSafe.firstValue(json, ["UserId", "userId"])),
        statusId:
            JsonSafe.asInt(JsonSafe.firstValue(json, ["StatusId", "statusId"])),
        pSize: JsonSafe.asInt(json["pSize"]),
        pNo: JsonSafe.asInt(JsonSafe.firstValue(json, ["PNo", "pNo"])),
        sSearch: JsonSafe.asString(
            JsonSafe.firstValue(json, ["sSearch", "search"])),
      );

  /// Common tenant body (PascalCase + `sSearch`).
  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "StatusId": statusId,
        "pSize": pSize,
        "PNo": pNo,
        "sSearch": sSearch
      };

  /// Sequel swagger `vehicleStatusRequest`.
  Map<String, dynamic> toSequelJson() => {
        "userId": userId,
        "statusId": statusId,
        "pSize": pSize,
        "pNo": pNo,
        "search": sSearch,
      };
}
