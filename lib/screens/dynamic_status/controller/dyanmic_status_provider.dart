import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infolocate/common_models/failure_model.dart';
import 'package:infolocate/screens/dynamic_status/model/dynamic_status_request_model.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/enums.dart';

import '../../../widgets/custom_toast.dart';
import '../model/dynamic_status_response_model.dart';
import '../respository/dyanmic_status_repo.dart';

/// Dynamic Status screen state: paginated list, search, and 10s background refresh.
///
/// Data source: [DynamicStatusService] → `vehicledetails` only (no dummy rows added).
/// [totalCount] comes from API `vehicleCnt[0].reccount`.
class DynamicStatusProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  bool _isMoreDataLoading = false;
  bool _hasMoreData = true;
  bool _isSearchLoading = false;

  NotifierState get state => _state;

  bool get isMoreDataLoading => _isMoreDataLoading;

  bool get hasMoreData => _hasMoreData;

  bool get isSearchLoading => _isSearchLoading;

  Failure get failure => _failure ?? Failure('');

  int? _totalCount = 0;
  int get totalCount => _totalCount!;

  List<DynamicStatusModelDataVehicledetails?>? _filterList = [];

  List<DynamicStatusModelDataVehicledetails?>? _dynamicStatusList = [];

  List<DynamicStatusModelDataVehicledetails?>? get dynamicStatusList =>
      [..._dynamicStatusList ?? []];

  List<DynamicStatusModelDataVehicledetails?>? get filterList =>
      [..._filterList ?? []];

  @override
  void setFailure(Failure failure) {
    setState(NotifierState.error);
    customToast(message: failure.message.toString());
    _failure = failure;
    notifyListeners();
  }

  @override
  void setState(NotifierState state) {
    _state = state;
    if (state == NotifierState.loading) {
      _isMoreDataLoading = true;
    } else {
      _isMoreDataLoading = false;
    }

    notifyListeners();
  }

  /// Resets list and pagination flags before a fresh load.
  clearDynamicList() {
    _hasMoreData = true;
    _isMoreDataLoading = false;
    _dynamicStatusList = _filterList = [];
    _totalCount = 0;
    notifyListeners();
  }

  /// Server-side search: replaces [filterList] with search API results.
  onSearchChange({
    required String? keyWord,
    required DynamicStatusRequestModel dynamicListRequestModel,
  }) async {
    _isSearchLoading = true;
    _hasMoreData = true;
    notifyListeners();
    try {
      final result = await DynamicStatusService().dynamicStatusListService(
          dynamicListRequestModel: dynamicListRequestModel);
      _filterList = result!.data!.vehicledetails;
      if (result.data!.vehicledetails!.isEmpty ||
          result.data!.vehicledetails!.length < pageSize) {
        _hasMoreData = false;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isSearchLoading = false;

    notifyListeners();
  }

  /// Silent refresh while user is on screen (skipped when search box is non-empty).
  fetchInBackground(
      {required DynamicStatusRequestModel dynamicListRequestModel}) async {
    final result = await DynamicStatusService().dynamicStatusListService(
        dynamicListRequestModel: dynamicListRequestModel);
    print(jsonEncode(result));
    _dynamicStatusList = result!.data!.vehicledetails;
    _filterList = _dynamicStatusList;
    notifyListeners();
  }

  /// Initial load or load-more pagination via [dynamicListRequestModel.PNo].
  getDynamicStatusList(
      {required DynamicStatusRequestModel dynamicListRequestModel,
      bool loadMore = false}) async {
    if (loadMore == false) {
      setState(NotifierState.loading);
      clearDynamicList();
    }
    try {
      final result = await DynamicStatusService().dynamicStatusListService(
          dynamicListRequestModel: dynamicListRequestModel);
      print(jsonEncode(result));
      if (result!.data!.vehicledetails!.isEmpty ||
          result.data!.vehicledetails!.length < pageSize) {
        // if (loadMore) customToast(message: LocaliazationKey.no_more_data.tr());
        _hasMoreData = false;
      } else {
        _hasMoreData = true;
      }
      _dynamicStatusList!.addAll(result.data!.vehicledetails!.toList());
      _filterList = _dynamicStatusList;
      if (result.data!.vehicleCnt!.isNotEmpty) {
        _totalCount = result.data!.vehicleCnt!.first!.reccount;
      }
      notifyListeners();
    } on Failure catch (failure) {
      loadMore == false
          ? setFailure(failure)
          : customToast(message: failure.message.toString());
    }
    if (loadMore == false) setState(NotifierState.loaded);
  }
}
