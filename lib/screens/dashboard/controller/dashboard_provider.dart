import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_helper.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/enums.dart';
import '../../../widgets/custom_toast.dart';
import '../model/dashboard_request_model.dart';
import '../model/dashboard_response_model.dart';
import '../repository/dashboard_repo.dart';

/// Dashboard home state: loads summary via [DashboardService].
class DashboardProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  DashboardResponseModelData? _dashboardResponseModelData;

  NotifierState get state => _state;

  Failure get failure => _failure ?? Failure('');

  DashboardResponseModelData? get dashboardResponseModelData =>
      _dashboardResponseModelData;

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _dashboardResponseModelData = null;
    setState(NotifierState.error);
    customToast(message: failure.message.toString());
    _failure = failure;
    notifyListeners();
  }

  // setLoading() {
  //   setState(NotifierState.loading);
  // }

  /// Fetches dashboard payload; sets [NotifierState.error] on network/API failure.
  Future<void> getData(
      {required DashboardRequestModel dashboardRequestModel}) async {
    try {
      final result = await DashboardService()
          .getDashboardData(dashboardRequestModel: dashboardRequestModel);

      _dashboardResponseModelData = result;
      _dashboardResponseModelData!.VehicleStatus!
          .sort((a, b) => a!.SequenceId!.compareTo(b!.SequenceId!.toInt()));
      for (var element in _dashboardResponseModelData!.VehicleStatus!) {
        element!.color = AppHelper.returnIconColor(title: element.status);
      }
      // _dashboardResponseModelData!.VehicleStatus!.insert(0, element)
    } on Failure catch (failure) {
      if (failure.message == LocaliazationKey.no_internet_connection.tr()) {
        setFailure(failure);
      }
    } catch (err) {
      print(err.toString());
    }
    notifyListeners();
  }

  updatePinValue({required int? vehicleId, bool value = true}) {
    final data = _dashboardResponseModelData!.Pinvehicle!.firstWhere(
        (element) => element!.VehicleId == vehicleId,
        orElse: () => DashboardResponseModelDataPinvehicle());
    if (data != null) {
      data.isPin = value;
    }

    notifyListeners();
  }

  getDashboardData(
      {required DashboardRequestModel dashboardRequestModel,
      bool backgroundFetch = false}) async {
    if (backgroundFetch == false) setState(NotifierState.loading);
    try {
      final result = await DashboardService()
          .getDashboardData(dashboardRequestModel: dashboardRequestModel);

      _dashboardResponseModelData = result;
      // _dashboardResponseModelData!.StatusCount!.add(
      //   DashboardResponseModelDataStatusCount(
      //     AlertCount: 43,
      //     AlertType: "Sharp Turn",
      //     AlertTypeID: 100,
      //     cardType: "D1",
      //     cid: 20,
      //     id: 30,
      //   ),
      // );
      // _dashboardResponseModelData!.StatusCount!.add(
      //   DashboardResponseModelDataStatusCount(
      //     AlertCount: 43,
      //     AlertType: "Harsh Brake",
      //     AlertTypeID: 99,
      //     cardType: "D1",
      //     cid: 19,
      //     id: 20,
      //   ),
      // );
      // _dashboardResponseModelData!.StatusCount!.add(
      //   DashboardResponseModelDataStatusCount(
      //     AlertCount: 43,
      //     AlertType: "Over Speed",
      //     AlertTypeID: 98,
      //     cardType: "D1",
      //     cid: 18,
      //     id: 10,
      //   ),
      // );
      _dashboardResponseModelData!.VehicleStatus!
          .sort((a, b) => a!.SequenceId!.compareTo(b!.SequenceId!.toInt()));
      for (var element in _dashboardResponseModelData!.VehicleStatus!) {
        element!.color = AppHelper.returnIconColor(title: element.status);
      }

      // _dashboardResponseModelData!.VehicleStatus = [];
      // _dashboardResponseModelData!.VehicleStatus!.add(
      //     DashboardResponseModelDataVehicleStatus(
      //         Cid: 45,
      //         StatusID: 45,
      //         Value: 34,
      //         cardType: "D3",
      //         status: "Demo"));
    } on Failure catch (failure) {
      setFailure(failure);
    } catch (err) {
      print(err.toString());
    }
    if (backgroundFetch == false) setState(NotifierState.loaded);
    notifyListeners();
  }

  int? getStatusByAlertType({required String? alertType}) {
    //* note pass alertType name same as original comining from API
    try {
      var result = dashboardResponseModelData!.StatusCount!.firstWhere(
          (status) => status!.AlertType == alertType,
          orElse: () => DashboardResponseModelDataStatusCount());
      if (result != null) return result.AlertTypeID;
    } catch (err) {
      debugPrint(err.toString());
    }
    return null;
  }
}
