import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infolocate/screens/dashboard/model/dashboard_request_model.dart';
import 'package:infolocate/screens/dashboard/model/dashboard_response_model.dart';
import 'package:infolocate/screens/dashboard/repository/sequel_dashboard_repo.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_lifecycle.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/custom_toast.dart';

import '../../../common_models/failure_model.dart';

/// Minimum gap between GetDashData page-1 fetches (auto refresh and duplicate triggers).
const Duration kSequelDashRefreshInterval = Duration(seconds: 30);

/// Sequel `GetDashData` state: summaries + paginated pin vehicles.
class SequelDashboardProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  DashboardResponseModelData? _data;
  int _pageNo = defaultPageN0;
  bool _hasMorePins = false;
  bool _loadingMore = false;
  bool _fetching = false;
  DateTime? _lastFetchAt;

  NotifierState get state => _state;
  Failure get failure => _failure ?? Failure('');
  DashboardResponseModelData? get data => _data;
  int get pageNo => _pageNo;
  bool get hasMorePins => _hasMorePins;
  bool get loadingMore => _loadingMore;
  DateTime? get lastFetchAt => _lastFetchAt;

  int get totalFleetCount {
    if (_data?.VehicleStatus == null) return 0;
    return _data!.VehicleStatus!.fold<int>(
      0,
      (sum, item) => sum + (item?.Value ?? 0),
    );
  }

  int get totalAlertCount {
    if (_data?.StatusCount == null) return 0;
    return _data!.StatusCount!.fold<int>(
      0,
      (sum, item) => sum + (item?.AlertCount ?? 0),
    );
  }

  List<DashboardResponseModelDataVehicleStatus> get vehicleStatuses =>
      AppHelper.sortVehicleStatuses(
        (_data?.VehicleStatus ?? const [])
            .whereType<DashboardResponseModelDataVehicleStatus>(),
        (item) => item.status,
      );

  List<DashboardResponseModelDataStatusCount> get rankedAlerts {
    final list = (_data?.StatusCount ?? const [])
        .whereType<DashboardResponseModelDataStatusCount>()
        .toList();
    list.sort((a, b) => (b.AlertCount ?? 0).compareTo(a.AlertCount ?? 0));
    return list;
  }

  List<DashboardResponseModelDataPinvehicle> get pinVehicles =>
      (_data?.Pinvehicle ?? const [])
          .whereType<DashboardResponseModelDataPinvehicle>()
          .toList();

  int get criticalAlertCount {
    return rankedAlerts.fold<int>(0, (sum, item) {
      final type = (item.AlertType ?? '').toLowerCase();
      if (type.contains('panic') || type.contains('power')) {
        return sum + (item.AlertCount ?? 0);
      }
      return sum;
    });
  }

  int get speedAlertCount {
    return rankedAlerts.fold<int>(0, (sum, item) {
      final type = (item.AlertType ?? '').toLowerCase();
      if (type.contains('speed') || type.contains('overspeed')) {
        return sum + (item.AlertCount ?? 0);
      }
      return sum;
    });
  }

  int get geofenceAlertCount {
    return rankedAlerts.fold<int>(0, (sum, item) {
      final type = (item.AlertType ?? '').toLowerCase();
      if (type.contains('geofence')) {
        return sum + (item.AlertCount ?? 0);
      }
      return sum;
    });
  }

  int get _userId => Global.savedUserAuthData?.userid ?? 0;

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure, {bool toast = true}) {
    _failure = failure;
    if (toast && _state != NotifierState.error) {
      customToast(message: failure.message.toString());
    }
    if (_data == null) {
      setState(NotifierState.error);
    } else {
      notifyListeners();
    }
  }

  Future<void> loadDashboard({
    bool showLoader = true,
    bool force = false,
  }) async {
    if (_userId <= 0) {
      setFailure(Failure('User session not found'));
      return;
    }
    if (!AppLifecycleTracker.instance.isStableForeground && !force) return;
    if (_fetching) return;
    if (!force && _lastFetchAt != null) {
      final elapsed = DateTime.now().difference(_lastFetchAt!);
      if (elapsed < kSequelDashRefreshInterval) return;
    }
    await _fetchDashboard(
      showLoader: showLoader && _data == null,
      allowRetry: true,
    );
  }

  Future<void> _fetchDashboard({
    required bool showLoader,
    required bool allowRetry,
  }) async {
    _fetching = true;
    _pageNo = defaultPageN0;
    if (showLoader) setState(NotifierState.loading);
    try {
      final result = await SequelDashboardService().getDashData(
        request: DashboardRequestModel(
          userId: _userId,
          pSize: pageSize,
          pNo: _pageNo,
        ),
      );
      final page = result.data ?? DashboardResponseModelData();
      _applyColors(page);
      _data = page;
      _hasMorePins = (page.Pinvehicle?.length ?? 0) >= pageSize;
      _lastFetchAt = DateTime.now();
      setState(NotifierState.loaded);
    } on Failure catch (failure) {
      await _handleLoadFailure(failure, allowRetry: allowRetry);
    } catch (err) {
      await _handleLoadFailure(Failure(err.toString()), allowRetry: allowRetry);
    } finally {
      _fetching = false;
    }
  }

  Future<void> _handleLoadFailure(
    Failure failure, {
    required bool allowRetry,
  }) async {
    if (_data != null) {
      setState(NotifierState.loaded);
      return;
    }
    if (!AppLifecycleTracker.instance.isResumed) {
      return;
    }
    if (allowRetry) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!AppLifecycleTracker.instance.isResumed) return;
      _fetching = false;
      await _fetchDashboard(showLoader: true, allowRetry: false);
      return;
    }
    setFailure(failure, toast: _state != NotifierState.error);
  }

  Future<void> loadNextPage() async {
    if (!_hasMorePins || _loadingMore || _fetching || _userId <= 0) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _pageNo + 1;
      final result = await SequelDashboardService().getDashData(
        request: DashboardRequestModel(
          userId: _userId,
          pSize: pageSize,
          pNo: nextPage,
        ),
      );
      final page = result.data;
      final newPins = page?.Pinvehicle ?? [];
      _pageNo = nextPage;
      _hasMorePins = newPins.length >= pageSize;
      if (page != null) {
        _applyColors(page);
        // Later pin pages must not wipe the overview counts when the
        // API omits vehicleStatus or statusCount.
        if (page.VehicleStatus != null && page.VehicleStatus!.isNotEmpty) {
          _data?.VehicleStatus = page.VehicleStatus;
        }
        if (page.StatusCount != null && page.StatusCount!.isNotEmpty) {
          _data?.StatusCount = page.StatusCount;
        }
      }
      _data?.Pinvehicle = [...?_data?.Pinvehicle, ...newPins];
    } on Failure catch (failure) {
      customToast(message: failure.message.toString());
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  void updatePinValue({required int? vehicleId, bool value = true}) {
    final pins = _data?.Pinvehicle;
    if (pins == null || vehicleId == null) return;
    for (final pin in pins) {
      if (pin?.VehicleId == vehicleId) {
        pin!.isPin = value;
        notifyListeners();
        return;
      }
    }
  }

  void _applyColors(DashboardResponseModelData page) {
    page.VehicleStatus?.sort(
      (a, b) => (a?.SequenceId ?? 0).compareTo(b?.SequenceId ?? 0),
    );
    for (final item in page.VehicleStatus ?? const []) {
      if (item == null) continue;
      item.color = AppHelper.returnIconColor(title: item.status);
    }
  }
}
