import '../../../utils/json_safe_parser.dart';

class HistoryTrackRequestModel with JsonSafeParser {
/*
{
  "userId": 1,
  "vehicleId": 34,
  "fromDatetime": "2023-05-11 00:00:00",
  "toDatetime": "2023-05-11 23:00:00"
}
*/

  int? UserId;
  int? VehicleID;
  String? FromDatetime;
  String? ToDatetime;

  HistoryTrackRequestModel({
    this.UserId,
    this.VehicleID,
    this.FromDatetime,
    this.ToDatetime,
  });
  HistoryTrackRequestModel.fromJson(Map<String, dynamic> json) {
    UserId = asIntFrom(json, ['userId', 'UserId']);
    VehicleID = asIntFrom(json, ['vehicleId', 'VehicleID', 'VehicleId']);
    FromDatetime = asStringFrom(json, ['fromDatetime', 'FromDatetime']);
    ToDatetime = asStringFrom(json, ['toDatetime', 'ToDatetime']);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': UserId,
      'vehicleId': VehicleID,
      'fromDatetime': FromDatetime,
      'toDatetime': ToDatetime,
    };
  }

  Map<String, dynamic> toCommonJson() {
    return {
      'UserId': UserId,
      'VehicleID': VehicleID,
      'FromDatetime': FromDatetime,
      'ToDatetime': ToDatetime,
    };
  }
}
