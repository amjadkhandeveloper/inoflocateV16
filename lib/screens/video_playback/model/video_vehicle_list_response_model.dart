import '../../login/model/client_model.dart';

class VideoVehicleListDataVehicles {
/*
{
  "VehicleId": 50,
  "VehicleNo": "27",
  "DelayEnable": 90,
  devicetype: "MDVR"
} 
*/

  int? VehicleId;
  String? VehicleNo;
  int? DelayEnable;
  String? deviceType;

  VideoVehicleListDataVehicles({
    this.VehicleId,
    this.VehicleNo,
    this.DelayEnable,
    this.deviceType
  });
  VideoVehicleListDataVehicles.fromJson(Map<String, dynamic> json) {
    VehicleId = json['VehicleId']?.toInt();
    VehicleNo = json['VehicleNo']?.toString();
    DelayEnable = json['DelayEnable']?.toInt();
    deviceType = json['devicetype'] ?? "";
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['VehicleId'] = VehicleId;
    data['VehicleNo'] = VehicleNo;
    data['DelayEnable'] = DelayEnable;
    data['devicetype'] = deviceType;
    return data;
  }

  operator [](String property) {
    switch (property) {
      case 'VehicleNo':
        return VehicleNo;
      case 'DelayEnable':
        return DelayEnable;
      case 'devicetype':
        return deviceType;
      default:
        throw ArgumentError('Invalid property: $property');
    }
  }
}

class VideoVehicleListData {
/*
{
  "status": 200,
  "vehicles": [
    {
      "VehicleId": 50,
      "VehicleNo": "27",
      "DelayEnable": 90
    }
  ]
} 
*/

  int? status;
  List<VideoVehicleListDataVehicles?>? vehicles;
  List<DataError?>? error;

  VideoVehicleListData({
    this.status,
    this.vehicles,
    this.error,
  });
  VideoVehicleListData.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toInt();
    if (json['vehicles'] != null) {
      final v = json['vehicles'];
      final arr0 = <VideoVehicleListDataVehicles>[];
      v.forEach((v) {
        arr0.add(VideoVehicleListDataVehicles.fromJson(v));
      });
      vehicles = arr0;
    }
    if (json['error'] != null) {
      final v = json['error'];
      final arr0 = <DataError>[];
      v.forEach((v) {
        arr0.add(DataError.fromJson(v));
      });
      error = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    if (vehicles != null) {
      final v = vehicles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['vehicles'] = arr0;
    }

    return data;
  }
}

class VideoVehicleList {
/*
{
  "data": {
    "status": 200,
    "vehicles": [
      {
        "VehicleId": 50,
        "VehicleNo": "27",
        "DelayEnable": 90,
        "devicetype":"MDVR"
      }
    ]
  }
} 
*/

  VideoVehicleListData? data;

  VideoVehicleList({
    this.data,
  });
  VideoVehicleList.fromJson(Map<String, dynamic> json) {
    data = (json['data'] != null)
        ? VideoVehicleListData.fromJson(json['data'])
        : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['data'] = this.data!.toJson();
    return data;
  }
}
