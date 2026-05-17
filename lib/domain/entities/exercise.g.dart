// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 1;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      workoutDayId: fields[1] as String,
      orderIndex: fields[2] as int,
      exerciseName: fields[3] as String,
      sets: fields[4] as int,
      minReps: fields[5] as int,
      maxReps: fields[6] as int,
      notes: fields[7] as String?,
      imagePath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutDayId)
      ..writeByte(2)
      ..write(obj.orderIndex)
      ..writeByte(3)
      ..write(obj.exerciseName)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.minReps)
      ..writeByte(6)
      ..write(obj.maxReps)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
