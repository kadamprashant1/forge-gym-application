// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseLogAdapter extends TypeAdapter<ExerciseLog> {
  @override
  final int typeId = 3;

  @override
  ExerciseLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseLog(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      exerciseId: fields[2] as String,
      setNumber: fields[3] as int,
      weight: fields[4] as double,
      repsCompleted: fields[5] as int,
      isPersonalRecord: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.exerciseId)
      ..writeByte(3)
      ..write(obj.setNumber)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.repsCompleted)
      ..writeByte(6)
      ..write(obj.isPersonalRecord);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
