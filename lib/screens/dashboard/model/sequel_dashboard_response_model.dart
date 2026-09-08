import 'dashboard_response_model.dart';

/// Parser for Sequel `GetDashData` (flat JSON, no `data` wrapper).
class SequelDashboardResponse {
  SequelDashboardResponse({
    this.status,
    this.message,
    this.data,
  });

  int? status;
  String? message;
  DashboardResponseModelData? data;

  bool get isSuccess => status == 1 || status == 200;

  factory SequelDashboardResponse.fromJson(Map<String, dynamic> json) {
    return SequelDashboardResponse(
      status: json['status']?.toInt(),
      message: json['message']?.toString(),
      data: DashboardResponseModelData(
        status: json['status']?.toInt(),
        VehicleStatus: _mapList(
          json['vehicleStatus'] ?? json['VehicleStatus'],
          DashboardResponseModelDataVehicleStatus.fromJson,
        ),
        StatusCount: _mapList(
          json['statusCount'] ?? json['StatusCount'],
          DashboardResponseModelDataStatusCount.fromJson,
        ),
        Pinvehicle: _mapList(
          json['pinvehicle'] ?? json['Pinvehicle'],
          DashboardResponseModelDataPinvehicle.fromJson,
        ),
      ),
    );
  }

  static List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (raw is! List) return <T>[];
    return raw
        .whereType<Map>()
        .map((item) => mapper(Map<String, dynamic>.from(item)))
        .toList();
  }
}
