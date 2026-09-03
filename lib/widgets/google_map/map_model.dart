import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapModel {
  final LatLng? latLng;
  final int? vehicleId;
  final String? vehicleNo;
  final String? statusName;
  final String? vehicleLocation;
  final String? vehicleTrackTime;
  final String? speed;
  final String? odometer;
  final String? ignition;
  final String? engineOffdelay;
  final String? idleduration;
  final String? stopduration;

  GoogleMapModel({
    required this.latLng,
    required this.vehicleId,
    this.vehicleNo,
    required this.statusName,
    required this.vehicleLocation,
    required this.vehicleTrackTime,
    required this.speed,
    required this.odometer,
    required this.ignition,
    required this.engineOffdelay,
    required this.idleduration,
    required this.stopduration,
  });
}
