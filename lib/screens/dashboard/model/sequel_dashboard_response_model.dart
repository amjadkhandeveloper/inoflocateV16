import '../../../utils/json_safe_parser.dart';
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
      status: JsonSafe.asInt(JsonSafe.firstValue(json, ['status', 'Status'])),
      message: JsonSafe.asString(json['message']),
      data: DashboardResponseModelData(
        status: JsonSafe.asInt(JsonSafe.firstValue(json, ['status', 'Status'])),
        VehicleStatus: JsonSafe.asListOfMaps(
          json['vehicleStatus'] ?? json['VehicleStatus'],
        ).map(DashboardResponseModelDataVehicleStatus.fromJson).toList(),
        StatusCount: JsonSafe.asListOfMaps(
          json['statusCount'] ?? json['StatusCount'],
        ).map(DashboardResponseModelDataStatusCount.fromJson).toList(),
        Pinvehicle: JsonSafe.asListOfMaps(
          json['pinvehicle'] ?? json['Pinvehicle'],
        ).map(DashboardResponseModelDataPinvehicle.fromJson).toList(),
      ),
    );
  }
}
