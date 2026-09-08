// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientModelDataClientAdapter extends TypeAdapter<ClientModelDataClient> {
  @override
  final int typeId = 1;

  @override
  ClientModelDataClient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientModelDataClient(
      clientId: fields[0] as int?,
      clientUrl: fields[1] as String?,
      currentVersion: fields[2] as int?,
      clientName: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClientModelDataClient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.clientId)
      ..writeByte(1)
      ..write(obj.clientUrl)
      ..writeByte(2)
      ..write(obj.currentVersion)
      ..writeByte(3)
      ..write(obj.clientName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientModelDataClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
