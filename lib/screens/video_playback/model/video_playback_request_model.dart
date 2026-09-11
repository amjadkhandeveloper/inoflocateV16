// To parse this JSON data, do
//
//     final videoPlayBackRequestModel = videoPlayBackRequestModelFromJson(jsonString);

import 'dart:convert';

import '../../../utils/json_safe_parser.dart';

VideoPlayBackRequestModel videoPlayBackRequestModelFromJson(String str) =>
    VideoPlayBackRequestModel.fromJson(json.decode(str));

String videoPlayBackRequestModelToJson(VideoPlayBackRequestModel data) =>
    json.encode(data.toJson());

class VideoPlayBackRequestModel {
  int? userId;
  int? vehicleId;
  String? startDate;
  String? endDate;

  VideoPlayBackRequestModel({
    required this.userId,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });

  factory VideoPlayBackRequestModel.fromJson(Map<String, dynamic> json) =>
      VideoPlayBackRequestModel(
        userId: JsonSafe.asInt(
            JsonSafe.firstValue(json, ["userId", "UserId"])),
        vehicleId: JsonSafe.asInt(
            JsonSafe.firstValue(json, ["vehicleId", "VehicleID", "VehicleId"])),
        startDate: JsonSafe.asString(JsonSafe.firstValue(
            json, ["fromDatetime", "StartDate", "startDate"])),
        endDate: JsonSafe.asString(JsonSafe.firstValue(
            json, ["toDatetime", "EndDate", "endDate"])),
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "VehicleID": vehicleId,
        "StartDate": startDate,
        "EndDate": endDate,
      };

  Map<String, dynamic> toSequelJson() => {
        "userId": userId,
        "vehicleId": vehicleId,
        "fromDatetime": startDate,
        "toDatetime": endDate,
      };
}
