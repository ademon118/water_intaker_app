// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_intake.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterIntakeAdapter extends TypeAdapter<WaterIntake> {
  @override
  final int typeId = 0;

  @override
  WaterIntake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterIntake(
      date: fields[0] as DateTime,
      amount: fields[1] as int,
      drinkType: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WaterIntake obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.drinkType)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterIntakeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
