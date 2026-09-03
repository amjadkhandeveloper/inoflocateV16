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


class DashboardModelVehicles {
  String? vehicleNumber;
  String? location;

  DashboardModelVehicles({
    this.vehicleNumber,
    this.location,
  });
  DashboardModelVehicles.fromJson(Map<String, dynamic> json) {
    vehicleNumber = json['vehicle_number']?.toString();
    location = json['location']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['vehicle_number'] = vehicleNumber;
    data['location'] = location;
    return data;
  }
}

class DashboardModelStatus {
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
    statusName = json['status_name']?.toString();
    totalCount = json['total_count']?.toString();
    percentage = json['percentage']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status_name'] = statusName;
    data['total_count'] = totalCount;
    data['percentage'] = percentage;
    return data;
  }
}

class DashboardModel {
  List<DashboardModelStatus?>? status;
  List<DashboardModelVehicles?>? vehicles;

  DashboardModel({
    this.status,
    this.vehicles,
  });
  DashboardModel.fromJson(Map<String, dynamic> json) {
    if (json['status'] != null) {
      final v = json['status'];
      final arr0 = <DashboardModelStatus>[];
      v.forEach((v) {
        arr0.add(DashboardModelStatus.fromJson(v));
      });
      status = arr0;
    }
    if (json['vehicles'] != null) {
      final v = json['vehicles'];
      final arr0 = <DashboardModelVehicles>[];
      v.forEach((v) {
        arr0.add(DashboardModelVehicles.fromJson(v));
      });
      vehicles = arr0;
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
