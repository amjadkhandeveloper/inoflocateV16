import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/widgets/custom_toast.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/enums.dart';
import '../../vehicle_statuswise_list/model/vehicle_status_request_model.dart';
import '../../vehicle_statuswise_list/model/vehicle_status_response_model.dart';
import '../../vehicle_statuswise_list/repository/vehicle_status_repo.dart';
import '../model/video_playback_request_model.dart';
import '../model/video_playback_response_model.dart';
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
  List<VideoVehicleListDataVehicles> _allVehicles = [];
  List<VideoVehicleListDataVehicles> get allVehicles => _allVehicles;

  VideoVehicleListDataVehicles? _selectedVehicle;
  VideoVehicleListDataVehicles? get selectedVehicle => _selectedVehicle;

  String? _playBackUrl;
  String? get playBackUrl => _playBackUrl;
  VideoPlayBackResponseModelDataPlaybackvideo? _playbackVideo;
  VideoPlayBackResponseModelDataPlaybackvideo? get playbackVideo =>
      _playbackVideo;
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

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
    customToast(message: failure.message.toString(), color: Colors.red);
    _failure = failure;
    notifyListeners();
  }

  getVehicleList() async {
    setState(NotifierState.loading);
    try {
      final userId = Global.savedUserAuthData!.userid!.toInt();
      if (Global.isSequelClient) {
        // Sequel has no dedicated vehiclesList API; reuse status-wise list
        // (same source as Track History) so the user can pick any vehicle.
        final result = await VehicleStatusService().getVehicleList(
          vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
            userId: userId,
            statusId: 6,
            pSize: 0,
            pNo: defaultPageN0,
            sSearch: '',
          ),
        );
        _allVehicles = (result?.vehicleStatusdetails ?? const [])
            .whereType<VehicleStatusResponseModelDataVehicleStatusdetails>()
            .where((vehicle) => (vehicle.VehicleNo ?? '').trim().isNotEmpty)
            .map(
              (vehicle) => VideoVehicleListDataVehicles(
                VehicleId: vehicle.Vehicleid,
                VehicleNo: vehicle.VehicleNo,
                DelayEnable: 1,
                deviceType: vehicle.devicetype,
              ),
            )
            .toList()
          ..sort(
            (a, b) => (a.VehicleNo ?? '')
                .toLowerCase()
                .compareTo((b.VehicleNo ?? '').toLowerCase()),
          );
      } else {
        final result =
            await VideoPlayBackService().getVehicleList(userId: userId);
        _vehicleList = result;
        _allVehicles = (result?.vehicles ?? const [])
            .whereType<VideoVehicleListDataVehicles>()
            .where((v) => (v.VehicleNo ?? '').trim().isNotEmpty)
            .toList();
        _allVehicles.sort(
          (a, b) => (b.DelayEnable ?? 0).compareTo(a.DelayEnable ?? 0),
        );
      }
      _selectedVehicle = null;
      log('Video vehicles stored: ${_allVehicles.length}');
      setState(NotifierState.loaded);
    } on Failure catch (failure) {
      setFailure(failure);
      setState(NotifierState.error);
    } catch (error) {
      log('Video playback vehicle list error: $error');
      setFailure(Failure(error.toString()));
      setState(NotifierState.error);
    }
  }

  generateVideoPlayback(
      VideoPlayBackRequestModel videoPlayBackRequestModel) async {
    // Keep the form on screen. Full-screen [NotifierState.loading] was leaving
    // the spinner up if the generate API returned an empty/malformed payload.
    _isGenerating = true;
    _playBackUrl = null;
    _playbackVideo = null;
    notifyListeners();
    try {
      final result = await VideoPlayBackService().generateVideoPlayback(
          videoPlayBackRequestModel: videoPlayBackRequestModel);
      final playback = result?.firstPlayback;
      final url = playback?.Purl?.trim();
      final playbackList = result?.playbackvideo ?? const [];
      if (playbackList.isEmpty || playback == null || url == null || url.isEmpty) {
        customToast(
          message: LocaliazationKey.no_video_available_for_playback.tr(),
        );
        return;
      }
      _playbackVideo = playback;
      _playBackUrl = url;
      log("PlayBack Url $_playBackUrl");
    } on Failure catch (failure) {
      setFailure(failure);
    } catch (error) {
      log('Generate video playback error: $error');
      setFailure(Failure(error.toString()));
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Uses vehicles that already have playback data, such as Sequel pins with a live URL.
  void setVehicles(List<VideoVehicleListDataVehicles> vehicles) {
    _allVehicles = vehicles
        .where((v) => (v.VehicleNo ?? '').trim().isNotEmpty)
        .toList();
    _selectedVehicle = null;
    _failure = null;
    setState(NotifierState.loaded);
  }

  void selectVehicle(VideoVehicleListDataVehicles? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  int returnVehicleId({required String vehicleNo}) {
    for (final value in _allVehicles) {
      if (value.VehicleNo == vehicleNo) {
        return value.VehicleId ?? 0;
      }
    }
    return _selectedVehicle?.VehicleId ?? 0;
  }
}
