import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infolocate/screens/video_playback/model/video_playback_request_model.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/widgets/custom_toast.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/enums.dart';
import '../model/video_vehicle_list_response_model.dart';
import '../repository/video_playback_repo.dart';

/// Video playback: vehicle dropdown list and generated playback URLs.
class VideoPlayBackProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  VideoVehicleListData? _vehicleList;

  NotifierState get state => _state;

  Failure get failure => _failure!;

  VideoVehicleListData? get vehicleList => _vehicleList;

  // final List<String> _svehicleIdList = [];
  // List<VideoVehicleListDataVehicles?>? _filteredList = [];
  List<VideoVehicleListDataVehicles?> _allVehicles = [];
  // List<VideoVehicleListDataVehicles?>? get filteredList => _filteredList;
  List<VideoVehicleListDataVehicles?>? get allVehicles => _allVehicles;
  String? _playBackUrl;
  String? get playBackUrl => _playBackUrl;

  loadingFalse() {
    setState(NotifierState.loaded);
    notifyListeners();
  }

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _vehicleList = null;
    customToast(message: failure.message.toString(), color: Colors.red);
    _failure = failure;
    notifyListeners();
  }

  getVehicleList() async {
    setState(NotifierState.loading);
    try {
      final result = await VideoPlayBackService()
          .getVehicleList(userId: Global.savedUserAuthData!.userid!.toInt());
      // print(jsonEncode(result));
      _vehicleList = result;
      _allVehicles = [];
      for (var value in _vehicleList!.vehicles!) {
        _allVehicles.add(value!);
      }
      _allVehicles.sort(
        (a, b) => b!.DelayEnable!.compareTo(a!.DelayEnable!),
      );
      // _allVehicles.insert(0, VideoVehicleListDataVehicles(VehicleNo: select));

      // _filteredList = vehicleList!.vehicles!
      //     .where(
      //       (element) => element!.DelayEnable! > 0,
      //     )
      //     .toList();
      // _filteredList!.insert(0, VideoVehicleListDataVehicles(VehicleNo: select));

      // for (int i = 0; i <= _vehicleList!.vehicles!.length; i++) {
      //   if (_vehicleList!.vehicles![i]!.DelayEnable! > 0) {
      //     _vehicleIdList.add(_vehicleList!.vehicles![i]!.VehicleId.toString());
      //   }
      // }
      // log("Vehicle Id List $_vehicleIdList");
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
  }

  generateVideoPlayback(
      VideoPlayBackRequestModel videoPlayBackRequestModel) async {
    setState(NotifierState.loading);
    try {
      final result = await VideoPlayBackService().generateVideoPlayback(
          videoPlayBackRequestModel: videoPlayBackRequestModel);
      _playBackUrl = result!.playbackvideo![0]!.Purl;
      log("PlayBack Url $_playBackUrl");
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
  }

  int returnVehicleId({required String vehicleNo}) {
    int vehicleId = 0;
    for (var value in _allVehicles) {
      if (value!.VehicleNo == vehicleNo) {
        vehicleId = value.VehicleId!;
        break;
      }
    }
    return vehicleId;
  }
}
