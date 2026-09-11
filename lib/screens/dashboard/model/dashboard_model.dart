import '../../../utils/json_safe_parser.dart';

class Properties {
  final String? name;
  final String? count;
  final String? icon;
  Properties({this.icon, this.name, this.count});
}

class ButtonModel {
  final String? title;
  final String? icon;

  ButtonModel({this.title, this.icon});
}


class DashboardModelVehicles with JsonSafeParser {
  String? vehicleNumber;
  String? location;

  DashboardModelVehicles({
    this.vehicleNumber,
    this.location,
  });
  DashboardModelVehicles.fromJson(Map<String, dynamic> json) {
    vehicleNumber = asString(json['vehicle_number']);
    location = asString(json['location']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['vehicle_number'] = vehicleNumber;
    data['location'] = location;
    return data;
  }
}

class DashboardModelStatus with JsonSafeParser {
  String? statusName;
  String? totalCount;
  String? percentage;
  String? icon;
  

  DashboardModelStatus({
    this.statusName,
    this.totalCount,
    this.icon,
    this.percentage,
  });
  DashboardModelStatus.fromJson(Map<String, dynamic> json) {
    statusName = asString(json['status_name']);
    totalCount = asString(json['total_count']);
    percentage = asString(json['percentage']);
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status_name'] = statusName;
    data['total_count'] = totalCount;
    data['percentage'] = percentage;
    return data;
  }
}

class DashboardModel with JsonSafeParser {
  List<DashboardModelStatus?>? status;
  List<DashboardModelVehicles?>? vehicles;

  DashboardModel({
    this.status,
    this.vehicles,
  });
  DashboardModel.fromJson(Map<String, dynamic> json) {
    if (json['status'] != null) {
      status = asListOfMaps(json['status'])
          .map(DashboardModelStatus.fromJson)
          .toList();
    }
    if (json['vehicles'] != null) {
      vehicles = asListOfMaps(json['vehicles'])
          .map(DashboardModelVehicles.fromJson)
          .toList();
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (status != null) {
      final v = status;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['status'] = arr0;
    }
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
