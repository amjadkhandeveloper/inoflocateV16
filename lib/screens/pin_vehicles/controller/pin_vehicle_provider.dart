import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../common_models/failure_model.dart';
import '../../../utils/enums.dart';
import '../../../widgets/custom_toast.dart';
import '../model/pin_vehicle_request_model.dart';
import '../model/pin_vehicle_response_model.dart';
import '../repository/pin_vehicle_repo.dart';

/// Pin / unpin vehicles on dashboard (max 6 pins enforced in UI).
class PinVehicleProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;
  PinVehicleResponseModelData? _pinVehicleResponseModel;
  int? _lengthOfPinVehicles;

  NotifierState get state => _state;

  Failure get failure => _failure!;

  PinVehicleResponseModelData? get pinVehicleResponseModel =>
      _pinVehicleResponseModel;

  int? get lengthOfPinVehicles => _lengthOfPinVehicles;

  set lengthOfPinVehicles(int? length) {
    _lengthOfPinVehicles = length;
    notifyListeners();
  }

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _pinVehicleResponseModel = null;
    customToast(message: failure.message.toString(), color: Colors.red);
    _failure = failure;
    notifyListeners();
  }

  pinUnpinVehicle(
      {required PinVehicleRequestModel pinVehicleRequestModel}) async {
    setState(NotifierState.loading);
    try {
      final result = await PinVehicleService()
          .pinUnpinVehicle(pinVehicleRequestModel: pinVehicleRequestModel);
      print(jsonEncode(result));
      _pinVehicleResponseModel = result;
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
  }
}
