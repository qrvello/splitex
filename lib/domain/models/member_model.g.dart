// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemberAdapter extends TypeAdapter<Member> {
  @override
  final int typeId = 1;

  @override
  Member read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Member(
      name: fields[2] as String?,
      id: fields[0] as String?,
      balance: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
