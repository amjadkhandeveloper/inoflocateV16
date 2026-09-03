// To parse this JSON data, do
//
//     final videoPlayBackRequestModel = videoPlayBackRequestModelFromJson(jsonString);

import 'dart:convert';

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
        userId: json["UserId"],
        vehicleId: json["VehicleID"],
        startDate: json["StartDate"],
        endDate: json["EndDate"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "VehicleID": vehicleId,
        "StartDate": startDate,
        "EndDate": endDate,
      };
}
