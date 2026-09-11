import '../../../utils/json_safe_parser.dart';
import '../../login/model/client_model.dart';

class VideoVehicleListDataVehicles with JsonSafeParser {
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
    VehicleId = asIntFrom(json, ['VehicleId', 'vehicleId']);
    VehicleNo = asStringFrom(json, ['VehicleNo', 'vehicleNo']);
    DelayEnable = asIntFrom(json, ['DelayEnable', 'delayEnable']);
    deviceType = asStringFrom(json, ['devicetype', 'deviceType', 'DeviceType']);
  }

  bool get isPlaybackEnabled => (DelayEnable ?? 0) > 0;

  @override
  String toString() => VehicleNo ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoVehicleListDataVehicles &&
          VehicleId == other.VehicleId &&
          VehicleNo == other.VehicleNo;

  @override
  int get hashCode => Object.hash(VehicleId, VehicleNo);
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

class VideoVehicleListData with JsonSafeParser {
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
    status = asIntFrom(json, ['status', 'Status']);
    vehicles = asListOfMaps(firstValue(json, [
      'vehicles',
      'Vehicles',
      'vehicleList',
      'VehicleList',
    ]))
        .map(VideoVehicleListDataVehicles.fromJson)
        .toList();
    error = asListOfMaps(firstValue(json, ['error', 'Error']))
        .map(DataError.fromJson)
        .toList();
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

class VideoVehicleList with JsonSafeParser {
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
    final nested = asMapOrNull(firstValue(json, ['data', 'Data']));
    if (nested != null) {
      data = VideoVehicleListData.fromJson(nested);
      return;
    }
    final list = asListOrNull(firstValue(json, ['data', 'Data', 'vehicles', 'Vehicles']));
    if (list != null) {
      data = VideoVehicleListData(
        vehicles: asListOfMaps(list)
            .map(VideoVehicleListDataVehicles.fromJson)
            .toList(),
      );
      return;
    }
    data = VideoVehicleListData.fromJson(json);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['data'] = this.data!.toJson();
    return data;
  }
}
