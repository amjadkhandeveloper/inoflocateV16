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
        clientId: JsonSafe.asInt(
            JsonSafe.firstValue(json, ["clientId", "ClientId"])),
        userId: JsonSafe.asInt(
            JsonSafe.firstValue(json, ["userId", "UserId"])),
        vehicleid: JsonSafe.asInt(JsonSafe.firstValue(
            json, ["vehicleId", "Vehicleid", "VehicleID"])),
        insertMode: JsonSafe.asInt(
            JsonSafe.firstValue(json, ["insertMode", "InsertMode"])),
      );

  Map<String, dynamic> toJson() => {
        "ClientId": clientId,
        "UserId": userId,
        "Vehicleid": vehicleid,
        "InsertMode": insertMode,
      };

  Map<String, dynamic> toSequelJson() => {
        "userId": userId,
        "clientId": clientId,
        "vehicleId": vehicleid,
        "insertMode": insertMode,
      };
}
