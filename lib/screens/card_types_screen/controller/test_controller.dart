// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:infolocate/screens/card_types_screen/model/card_type_setting_model.dart';
// import 'package:infolocate/screens/card_types_screen/view/card_type_screen.dart';
// import 'package:infolocate/utils/app_globals.dart';

// import '../../../utils/app_constants.dart';
// import '../../../utils/app_helper.dart';
// import '../../../utils/app_localization_key.dart';
// import '../../../widgets/custom_toast.dart';

// class TestProvider extends ChangeNotifier {
//   CardTypeSetting _cardTypeSetting = CardTypeSetting(alertStatusCardsList: [
//     CardTypeModel(cardTypeId: 1),
//     CardTypeModel(cardTypeId: 2),
//     CardTypeModel(cardTypeId: 3),
//     CardTypeModel(cardTypeId: 4),
//     CardTypeModel(cardTypeId: 5),
//     CardTypeModel(cardTypeId: 6),
//   ], vehicleStatusCardsList: [
//     CardTypeModel(cardTypeId: 1),
//     CardTypeModel(cardTypeId: 2),
//     CardTypeModel(cardTypeId: 3),
//   ]);

//   CardTypeSetting get cardTypeSetting => _cardTypeSetting;

//   CardTypeModel? get currentSelectedVehicleStatusCard {
//     final card = _cardTypeSetting.vehicleStatusCardsList!.firstWhere(
//       (element) => element!.isSelected == true,
//       orElse: () => _cardTypeSetting.vehicleStatusCardsList!.first,
//     );
//     return CardTypeModel(cardTypeId: card!.cardTypeId);
//   }

//   CardTypeModel? get currentSelectedAlertStatusCard {
//     final card = _cardTypeSetting.alertStatusCardsList!.firstWhere(
//       (element) => element!.isSelected == true,
//       orElse: () => _cardTypeSetting.alertStatusCardsList!.first,
//     );
//     return CardTypeModel(cardTypeId: card!.cardTypeId);
//   }

//   initialiseCardSettings() {
//     if (Global.cardTypeSetting != null) {
//       _cardTypeSetting = Global.cardTypeSetting!;
//     }
//     notifyListeners();
//   }

//   selectVehicleStatusCard({required int? cardTypeId}) async {
//     for (var card in _cardTypeSetting.vehicleStatusCardsList!) {
//       card!.isSelected = false;
//       if (card.cardTypeId == cardTypeId) {
//         card.isSelected = true;
//       } else {
//         card.isSelected = false;
//       }
//     }
//     notifyListeners();
//   }

//   selectAlertStatusCard({required int? cardTypeId}) async {
//     for (var card in _cardTypeSetting.alertStatusCardsList!) {
//       card!.isSelected = false;
//       if (card.cardTypeId == cardTypeId) {
//         card.isSelected = true;
//       } else {
//         card.isSelected = false;
//       }
//     }
//     notifyListeners();
//   }

//   Future<void> saveCardSettingsToHive() async {
//     await Global.box.put(cardTypeSettingKey, _cardTypeSetting);
//     await AppHelper.getHiveBoxData();
//     customToast(
//       message: LocaliazationKey.card_settings_updated.tr(),
//     );
//   }
// }
