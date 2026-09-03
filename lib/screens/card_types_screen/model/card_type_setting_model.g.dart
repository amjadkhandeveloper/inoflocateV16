// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_type_setting_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardTypeSettingAdapter extends TypeAdapter<CardTypeSetting> {
  @override
  final int typeId = 3;

  @override
  CardTypeSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardTypeSetting(
      vehicleStatusCardsList: (fields[0] as List?)?.cast<CardTypeModel?>(),
      alertStatusCardsList: (fields[1] as List?)?.cast<CardTypeModel?>(),
    );
  }

  @override
  void write(BinaryWriter writer, CardTypeSetting obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.vehicleStatusCardsList)
      ..writeByte(1)
      ..write(obj.alertStatusCardsList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTypeSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
