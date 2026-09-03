import 'package:flutter/material.dart';
import 'package:infolocate/screens/dashboard/repository/ads_repo.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/enums.dart';
import '../model/ads_response_model.dart';

/// Loads optional banner ads on dashboard via [AdsService].
class AdsProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  AdsResponseModelData? _adsResponseModelData;

  NotifierState get state => _state;

  Failure get failure => _failure ?? Failure('');

  AdsResponseModelData? get adsResponseModelData => _adsResponseModelData;
  List<String> _urlList = [];
  List<String> get urlList => _urlList;

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _adsResponseModelData = null;
    setState(NotifierState.error);
    // customToast(message: failure.message.toString());
    _failure = failure;
    notifyListeners();
  }

  Future<void> getAds(
      {required int clientId, bool backgroundFetch = false}) async {
    setState(NotifierState.loading);
    try {
      final result = await AdsService().getAds(clientId: clientId);
      _adsResponseModelData = result;
      _urlList = [];
      if (_adsResponseModelData!.advertise!.isNotEmpty) {
        for (var url in _adsResponseModelData!.advertise!) {
          _urlList.add(url!.ClientAdvertiseUrl.toString());
        }
      }
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
    notifyListeners();
  }
}
