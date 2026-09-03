import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/alerts/model/alert_list_request_model.dart';
import 'package:infolocate/screens/alerts/respositroy/alert_repo.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/enums.dart';
import '../../../widgets/custom_toast.dart';
import '../model/alert_list_response_model.dart';

/// Alert list state: pagination, search, and filter (mirrors dynamic status pattern).
class AlertProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  bool _isMoreDataLoading = false;
  bool _hasMoreData = false;
  bool _isSearchLoading = false;
  int? _totalCount = 0;

  List<AlertListResponseModelDataAlertdetails?>? _alertList = [];
  List<AlertListResponseModelDataAlertdetails?>? _filterList = [];
  List<AlertListResponseModelDataAlerttypes?>? _alertTypesFilterList = [];

  //* getters
  NotifierState get state => _state;

  Failure get failure => _failure!;

  bool get isMoreDataLoading => _isMoreDataLoading;

  bool get hasMoreData => _hasMoreData;

  bool get isSearchLoading => _isSearchLoading;
  int get totalCount => _totalCount!;

  List<AlertListResponseModelDataAlertdetails?>? get alertList =>
      [..._alertList ?? []];
  List<AlertListResponseModelDataAlertdetails?>? get filterList =>
      [..._filterList ?? []];

  List<AlertListResponseModelDataAlerttypes?>? get alertTypesFilterList =>
      [..._alertTypesFilterList ?? []];

  //*functions

  @override
  void setFailure(Failure failure) {
    customToast(message: failure.message.toString());
    _failure = failure;
    _state = NotifierState.error;
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

  // onSearchChange({required String? keyWord}) {
  //   _filterList = alertList;
  //   _filterList!.retainWhere((alert) =>
  //           alert!.VehicleNo!.toLowerCase().contains(keyWord!.toLowerCase())
  //       //  ||
  //       //         alert.drivername != null
  //       //     ? alert.drivername!.toLowerCase().contains(keyWord.toLowerCase())
  //       //     : false
  //       );
  //   notifyListeners();

  // }

  onSearchChange({
    required String? keyWord,
    required AlertListRequestModel alertListRequestModel,
  }) async {
    _isSearchLoading = true;
    _hasMoreData = false;
    notifyListeners();
    try {
      final result = await AlertService()
          .alertListService(alertListRequestModel: alertListRequestModel);
      if (result == null && result!.alertdetails == null) return;
      _filterList = result.alertdetails;
    } catch (e) {
      debugPrint(e.toString());
    }
    _isSearchLoading = false;
    notifyListeners();
    // _filterList = dynamicStatusList;
    // _filterList!.retainWhere((data) =>
    //     data!.VehicleNo!.toLowerCase().contains(keyWord!.toLowerCase()));
  }

  clearAlerts() {
    _isMoreDataLoading = false;
    _hasMoreData = false;
    _alertList = _filterList = [];
    _totalCount = 0;
    notifyListeners();
  }

  // loadMoreAlets({required AlertListRequestModel alertListRequestModel}) async{
  //    try {
  //     print(jsonEncode(alertListRequestModel));
  //     final result = await AlertService()
  //         .alertListService(alertListRequestModel: alertListRequestModel);
  //     print(jsonEncode(result));
  //     if (result!.length < alertListRequestModel.pSize!.toInt()) {
  //       _hasMoreData = false;
  //     } else {
  //       _hasMoreData = true;
  //     }
  //     notifyListeners();
  //     _alertList!.addAll(result.toList());
  //     _filterList = _alertList;
  //   } on Failure catch (failure) {
  //     setFailure(failure);
  //   }
  // }

  getAlertListInBackground(
      {required AlertListRequestModel alertListRequestModel}) async {
    try {
      _isMoreDataLoading = true;
      _alertTypesFilterList = [];
      _alertTypesFilterList!.add(AlertListResponseModelDataAlerttypes(
          AlertType: LocaliazationKey.all.tr()));
      notifyListeners();
      final result = await AlertService()
          .alertListService(alertListRequestModel: alertListRequestModel);

      if (result!.alertdetails!.isEmpty ||
          result.alertdetails!.length < pageSize) {
        // customToast(message: LocaliazationKey.no_more_data.tr());
        _hasMoreData = false;
      } else {
        _hasMoreData = true;
      }
      _alertList!.addAll(result.alertdetails!.toList());
      _filterList = _alertList;
      if (result.alertcnt!.isNotEmpty) {
        _totalCount = result.alertcnt!.first!.TotRec!;
      }
      if (result.alerttypes!.isNotEmpty) {
        var data = result.alerttypes;
        for (var element in data!) {
          element!.AlertType = element.AlertType == "yaccel end" ||
                  element.AlertType == "xaccel end"
              ? AppHelper.returnJapaneseText(
                  title: AppHelper.returnAlertStatus(
                  alertStatus: element.AlertType,
                ))
              : AppHelper.returnJapaneseText(title: element.AlertType);
        }
        _alertTypesFilterList!.addAll(data);
      }

      notifyListeners();
    } on Failure catch (failure) {
      customToast(message: failure.message.toString());
    }
    _isMoreDataLoading = false;
    notifyListeners();
  }

  getAlertList({
    required AlertListRequestModel alertListRequestModel,
    // bool loadMore = false
  }) async {
    // if (loadMore == false) {
    setState(NotifierState.loading);
    clearAlerts();
    _alertTypesFilterList = [];
    _alertTypesFilterList!.add(AlertListResponseModelDataAlerttypes(
        AlertType: LocaliazationKey.all.tr()));
    // }
    try {
      final result = await AlertService()
          .alertListService(alertListRequestModel: alertListRequestModel);

      if (result!.alertdetails!.isEmpty ||
          result.alertdetails!.length < pageSize) {
        // if (loadMore) customToast(message: LocaliazationKey.no_more_data.tr());
        _hasMoreData = false;
      } else {
        _hasMoreData = true;
      }
      _alertList!.addAll(result.alertdetails!.toList());
      _filterList = _alertList;
      if (result.alertcnt!.isNotEmpty) {
        _totalCount = result.alertcnt!.first!.TotRec!;
      }
      if (result.alerttypes!.isNotEmpty) {
        var data = result.alerttypes;
        for (var element in data!) {
          element!.AlertType = element.AlertType == "yaccel end" ||
                  element.AlertType == "xaccel end"
              ? AppHelper.returnJapaneseText(
                  title: AppHelper.returnAlertStatus(
                  alertStatus: element.AlertType,
                ))
              : AppHelper.returnJapaneseText(title: element.AlertType);
        }
        _alertTypesFilterList!.addAll(data);
      }
      setState(NotifierState.loaded);
      notifyListeners();
    } on Failure catch (failure) {
      // loadMore == false
      //     ?
      setFailure(failure);
      // : customToast(message: failure.message.toString());
    }
    // if (loadMore == false)
  }
}
