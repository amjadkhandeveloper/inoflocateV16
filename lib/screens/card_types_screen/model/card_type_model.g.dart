// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardTypeModelAdapter extends TypeAdapter<CardTypeModel> {
  @override
  final int typeId = 2;

  @override
  CardTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardTypeModel(
      cardTypeId: fields[0] as int?,
      isSelected: fields[1] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CardTypeModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cardTypeId)
      ..writeByte(1)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
