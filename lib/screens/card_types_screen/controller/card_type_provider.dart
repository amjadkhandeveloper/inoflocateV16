import 'package:flutter/cupertino.dart';

import '../../../utils/app_globals.dart';
import '../model/card_type_model.dart';

class CardTypeProvider extends ChangeNotifier {
  // CardTypeSetting _cardTypeSetting = CardTypeSetting(alertStatusCardsList: [
  //   CardTypeModel(cardTypeId: 1, isSelected: true),
  //   CardTypeModel(cardTypeId: 2),
  //   CardTypeModel(cardTypeId: 3),
  // ], vehicleStatusCardsList: [
  //   CardTypeModel(cardTypeId: 1, isSelected: true),
  //   CardTypeModel(cardTypeId: 2),
  //   CardTypeModel(cardTypeId: 3),
  //   CardTypeModel(cardTypeId: 4),
  //   CardTypeModel(cardTypeId: 5),
  //   CardTypeModel(cardTypeId: 6),
  // ]);

  // CardTypeSetting get cardTypeSetting => _cardTypeSetting;

  // CardTypeModel? get currentSelectedVehicleStatusCard {
  //   final card = _cardTypeSetting.vehicleStatusCardsList!.firstWhere(
  //     (element) => element!.isSelected == true,
  //     orElse: () => _cardTypeSetting.vehicleStatusCardsList!.first,
  //   );
  //   return CardTypeModel(cardTypeId: card!.cardTypeId);
  // }

  // CardTypeModel? get currentSelectedAlertStatusCard {
  //   final card = _cardTypeSetting.alertStatusCardsList!.firstWhere(
  //     (element) => element!.isSelected == true,
  //     orElse: () => _cardTypeSetting.alertStatusCardsList!.first,
  //   );
  //   return CardTypeModel(cardTypeId: card!.cardTypeId);
  // }

  // initialiseCardSettings() async {
  //   await AppHelper.getHiveBoxData();
  //   if (Global.cardTypeSetting != null) {
  //     _cardTypeSetting = CardTypeSetting(alertStatusCardsList: [
  //       ...List.from(Global.cardTypeSetting!.alertStatusCardsList!)
  //     ], vehicleStatusCardsList: [
  //       ...List.from(Global.cardTypeSetting!.vehicleStatusCardsList!)
  //     ]);
  //   }
  //   Global.cardTypeSetting!.alertStatusCardsList!.forEach((element) =>
  //       print(element!.cardTypeId!.toString() + element.isSelected.toString()));
  //   notifyListeners();
  // }

  // selectVehicleStatusCard({required int? cardTypeId}) async {
  //   for (var card in _cardTypeSetting.vehicleStatusCardsList!) {
  //     card!.isSelected = false;
  //     if (card.cardTypeId == cardTypeId) {
  //       card.isSelected = true;
  //     } else {
  //       card.isSelected = false;
  //     }
  //   }
  //   notifyListeners();
  // }

  // selectAlertStatusCard({required int? cardTypeId}) async {
  //   for (var card in _cardTypeSetting.alertStatusCardsList!) {
  //     card!.isSelected = false;
  //     if (card.cardTypeId == cardTypeId) {
  //       card.isSelected = true;
  //     } else {
  //       card.isSelected = false;
  //     }
  //   }
  //   notifyListeners();
  // }

  // Future<void> saveCardSettingsToHive() async {
  //   await Global.box.put(cardTypeSettingKey, _cardTypeSetting);
  //   await AppHelper.getHiveBoxData();
  //   customToast(
  //     message: LocaliazationKey.card_settings_updated.tr(),
  //   );
  // }
  final _vehicleStatusCardsList = [
    CardTypeModel(cardTypeId: 1),
    // CardTypeModel(cardTypeId: 2),
    CardTypeModel(cardTypeId: 3),
    CardTypeModel(cardTypeId: 4),
    // CardTypeModel(cardTypeId: 5),
    CardTypeModel(cardTypeId: 6),
  ];

  final _alertStatusCardsList = [
    CardTypeModel(cardTypeId: 1),
    CardTypeModel(cardTypeId: 2),
    CardTypeModel(cardTypeId: 3),
    // CardTypeModel(cardTypeId: 4),
    // CardTypeModel(cardTypeId: 5),
    // CardTypeModel(cardTypeId: 6),
  ];

  List<CardTypeModel> get vehicleStatusCardsList =>
      [..._vehicleStatusCardsList];

  List<CardTypeModel> get alertStatusCardsList => [..._alertStatusCardsList];

  CardTypeModel? get currentSelectedVehicleStatusCard {
    final card = _vehicleStatusCardsList.firstWhere(
      (element) => element.isSelected == true,
      orElse: () => _vehicleStatusCardsList[0],
    );
    return CardTypeModel(cardTypeId: card.cardTypeId);
  }

  CardTypeModel? get currentSelectedAlertStatusCard {
    final card = _alertStatusCardsList.firstWhere(
      (element) => element.isSelected == true,
      orElse: () => _alertStatusCardsList[0],
    );
    return CardTypeModel(cardTypeId: card.cardTypeId);
  }

  setCurrentVehicleStatusCard() {
    if (Global.savedVehicleStatusCardTypeId == null) {
      _vehicleStatusCardsList.first.isSelected = true;

      notifyListeners();
      return;
    }
    for (var _card in _vehicleStatusCardsList) {
      if (_card.cardTypeId == Global.savedVehicleStatusCardTypeId) {
        _card.isSelected = true;
        notifyListeners();
      } else {
        _card.isSelected = false;
        notifyListeners();
      }
    }
  }

  setCurrentAlertStatusCard() {
    if (Global.savedAlertStatusCardTypeId == null) {
      _alertStatusCardsList.first.isSelected = true;

      notifyListeners();
      return;
    }
    for (var _card in _alertStatusCardsList) {
      if (_card.cardTypeId == Global.savedAlertStatusCardTypeId) {
        _card.isSelected = true;
        notifyListeners();
      } else {
        _card.isSelected = false;
        notifyListeners();
      }
    }
  }

  selectVehicleStatusCard({required int? cardTypeId}) async {
    for (var card in _vehicleStatusCardsList) {
      card.isSelected = false;
      if (card.cardTypeId == cardTypeId) {
        card.isSelected = true;
      } else {
        card.isSelected = false;
      }
    }
    notifyListeners();
  }

  selectAlertStatusCard({required int? cardTypeId}) async {
    for (var card in _alertStatusCardsList) {
      card.isSelected = false;
      if (card.cardTypeId == cardTypeId) {
        card.isSelected = true;
      } else {
        card.isSelected = false;
      }
    }
    notifyListeners();
  }
}
