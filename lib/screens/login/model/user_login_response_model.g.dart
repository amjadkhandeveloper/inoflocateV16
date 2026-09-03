// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLoginResponseModelDataUserAdapter
    extends TypeAdapter<UserLoginResponseModelDataUser> {
  @override
  final int typeId = 0;

  @override
  UserLoginResponseModelDataUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLoginResponseModelDataUser(
      userid: fields[0] as int?,
      username: fields[1] as String?,
      theme: fields[2] as int?,
      language: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserLoginResponseModelDataUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userid)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.theme)
      ..writeByte(3)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLoginResponseModelDataUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
