import 'package:hive/hive.dart';

import 'card_type_model.dart';

part 'card_type_setting_model.g.dart';

@HiveType(typeId: 3)
class CardTypeSetting {
  @HiveField(0)
  final List<CardTypeModel?>? vehicleStatusCardsList;
  @HiveField(1)
  final List<CardTypeModel?>? alertStatusCardsList;

  CardTypeSetting({this.vehicleStatusCardsList, this.alertStatusCardsList});
}
