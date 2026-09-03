import 'package:hive/hive.dart';

part 'card_type_model.g.dart';

@HiveType(typeId: 2)
class CardTypeModel {
  @HiveField(0)
  final int? cardTypeId;
  @HiveField(1)
  bool? isSelected;

  CardTypeModel({required this.cardTypeId, this.isSelected = false});
}
