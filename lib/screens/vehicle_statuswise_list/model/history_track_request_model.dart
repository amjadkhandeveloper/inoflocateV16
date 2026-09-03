
class HistoryTrackRequestModel {
/*
{
  "UserId": 1,
  "VehicleID": 34,
  "FromDatetime": "2023-05-11 00:00:00",
  "ToDatetime": "2023-05-11 23:00:00"
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
    UserId = json['UserId']?.toInt();
    VehicleID = json['VehicleID']?.toInt();
    FromDatetime = json['FromDatetime']?.toString();
    ToDatetime = json['ToDatetime']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['UserId'] = UserId;
    data['VehicleID'] = VehicleID;
    data['FromDatetime'] = FromDatetime;
    data['ToDatetime'] = ToDatetime;
    return data;
  }
}
