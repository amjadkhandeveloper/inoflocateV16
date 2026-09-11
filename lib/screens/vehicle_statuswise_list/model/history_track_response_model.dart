import '../../../utils/json_safe_parser.dart';

class VehicleHistoryTrackModelDataVehicleHistory with JsonSafeParser {
/*
{
  "VehicleId": 34,
  "ClientID": 1,
  "VehicleNo": "72070",
  "Unitno": "72070",
  "tracktime": "05/10/2023 03:00:04",
  "lat": 33.22932434082031,
  "lon": 131.6027374267578,
  "location": "〒870-0823 大分県大分市東大道２丁目５−６０",
  "speed": 0,
  "odometer": 1367.33,
  "direction": 321,
  "idleduration": 75080,
  "stopduration": 0,
  "AlertInd": 0,
  "Directions": 315,
  "VehicleType": "4 Wheeler"
} 
*/

  int? VehicleId;
  int? ClientID;
  String? VehicleNo;
  String? Unitno;
  String? tracktime;
  double? lat;
  double? lon;
  String? location;
  int? speed;
  double? odometer;
  int? direction;
  int? idleduration;
  int? stopduration;
  int? AlertInd;
  int? Directions;
  String? VehicleType;
  String? uniqueId;  //* added externally for markers

  VehicleHistoryTrackModelDataVehicleHistory(
      {this.VehicleId,
      this.ClientID,
      this.VehicleNo,
      this.Unitno,
      this.tracktime,
      this.lat,
      this.lon,
      this.location,
      this.speed,
      this.odometer,
      this.direction,
      this.idleduration,
      this.stopduration,
      this.AlertInd,
      this.Directions,
      this.VehicleType,
      this.uniqueId});
  VehicleHistoryTrackModelDataVehicleHistory.fromJson(
      Map<String, dynamic> json) {
    VehicleId = asIntFrom(json, ['VehicleId', 'vehicleId']);
    ClientID = asIntFrom(json, ['ClientID', 'clientId', 'ClientId']);
    VehicleNo = asStringFrom(json, ['VehicleNo', 'vehicleNo']);
    Unitno = asStringFrom(json, ['Unitno', 'unitno', 'unitNo']);
    tracktime =
        asStringFrom(json, ['tracktime', 'trackTime', 'TrackingTime']);
    lat = asDoubleOrNull(firstValue(json, ['lat', 'latitude']));
    lon = asDoubleOrNull(firstValue(json, ['lon', 'lng', 'longitude']));
    location = asString(json['location']);
    speed = asInt(json['speed']);
    odometer = asDouble(json['odometer']);
    direction = asInt(json['direction']);
    idleduration = asInt(json['idleduration']);
    stopduration = asInt(json['stopduration']);
    AlertInd = asInt(json['AlertInd']);
    Directions = asInt(json['Directions']);
    VehicleType = asString(json['VehicleType']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['VehicleId'] = VehicleId;
    data['ClientID'] = ClientID;
    data['VehicleNo'] = VehicleNo;
    data['Unitno'] = Unitno;
    data['tracktime'] = tracktime;
    data['lat'] = lat;
    data['lon'] = lon;
    data['location'] = location;
    data['speed'] = speed;
    data['odometer'] = odometer;
    data['direction'] = direction;
    data['idleduration'] = idleduration;
    data['stopduration'] = stopduration;
    data['AlertInd'] = AlertInd;
    data['Directions'] = Directions;
    data['VehicleType'] = VehicleType;
    return data;
  }
}

class VehicleHistoryTrackModelData with JsonSafeParser {
/*
{
  "status": 200,
  "VehicleHistory": [
    {
      "VehicleId": 34,
      "ClientID": 1,
      "VehicleNo": "72070",
      "Unitno": "72070",
      "tracktime": "05/10/2023 03:00:04",
      "lat": 33.22932434082031,
      "lon": 131.6027374267578,
      "location": "〒870-0823 大分県大分市東大道２丁目５−６０",
      "speed": 0,
      "odometer": 1367.33,
      "direction": 321,
      "idleduration": 75080,
      "stopduration": 0,
      "AlertInd": 0,
      "Directions": 315,
      "VehicleType": "4 Wheeler"
    }
  ]
} 
*/

  int? status;
  List<VehicleHistoryTrackModelDataVehicleHistory?>? VehicleHistory;

  VehicleHistoryTrackModelData({
    this.status,
    this.VehicleHistory,
  });
  VehicleHistoryTrackModelData.fromJson(Map<String, dynamic> json) {
    status = asIntFrom(json, ['status', 'Status']);
    final raw = asListOrNull(
        firstValue(json, ['VehicleHistory', 'vehicleHistory', 'history']));
    if (raw != null) {
      VehicleHistory = asListOfMaps(raw)
          .map(VehicleHistoryTrackModelDataVehicleHistory.fromJson)
          .toList();
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    if (VehicleHistory != null) {
      final v = VehicleHistory;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['VehicleHistory'] = arr0;
    }
    return data;
  }
}

class VehicleHistoryTrackModel with JsonSafeParser {
/*
{
  "data": {
    "status": 200,
    "VehicleHistory": [
      {
        "VehicleId": 34,
        "ClientID": 1,
        "VehicleNo": "72070",
        "Unitno": "72070",
        "tracktime": "05/10/2023 03:00:04",
        "lat": 33.22932434082031,
        "lon": 131.6027374267578,
        "location": "〒870-0823 大分県大分市東大道２丁目５−６０",
        "speed": 0,
        "odometer": 1367.33,
        "direction": 321,
        "idleduration": 75080,
        "stopduration": 0,
        "AlertInd": 0,
        "Directions": 315,
        "VehicleType": "4 Wheeler"
      }
    ]
  }
} 
*/

  VehicleHistoryTrackModelData? data;

  VehicleHistoryTrackModel({
    this.data,
  });
  VehicleHistoryTrackModel.fromJson(Map<String, dynamic> json) {
    final dataMap = asMapOrNull(json['data']);
    if (dataMap != null) {
      data = VehicleHistoryTrackModelData.fromJson(dataMap);
    } else if (json['VehicleHistory'] != null ||
        json['vehicleHistory'] != null ||
        json['history'] != null) {
      data = VehicleHistoryTrackModelData.fromJson(json);
    }
  }
  Map<String, dynamic> toJson() {
    final res = <String, dynamic>{};
    if (data != null) {
      res['data'] = data!.toJson();
    }
    return res;
  }
}
