// To parse this JSON data, do
//
//     final pinVehicleRequestModel = pinVehicleRequestModelFromJson(jsonString);

import 'dart:convert';

import '../../../utils/json_safe_parser.dart';

PinVehicleRequestModel pinVehicleRequestModelFromJson(String str) =>
    PinVehicleRequestModel.fromJson(json.decode(str));

String pinVehicleRequestModelToJson(PinVehicleRequestModel data) =>
    json.encode(data.toJson());

class PinVehicleRequestModel {
  int clientId;
  int userId;
  int vehicleid;
  int insertMode;

  PinVehicleRequestModel({
    required this.clientId,
    required this.userId,
    required this.vehicleid,
    required this.insertMode,
  });

  factory PinVehicleRequestModel.fromJson(Map<String, dynamic> json) =>
      PinVehicleRequestModel(
        clientId: JsonSafe.asInt(json["ClientId"]),
        userId: JsonSafe.asInt(json["UserId"]),
        vehicleid: JsonSafe.asInt(json["Vehicleid"]),
        insertMode: JsonSafe.asInt(json["InsertMode"]),
      );

  Map<String, dynamic> toJson() => {
        "ClientId": clientId,
        "UserId": userId,
        "Vehicleid": vehicleid,
        "InsertMode": insertMode,
      };
}
