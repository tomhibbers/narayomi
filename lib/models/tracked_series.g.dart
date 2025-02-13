// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_series.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackedSeriesAdapter extends TypeAdapter<TrackedSeries> {
  @override
  final int typeId = 5;

  @override
  TrackedSeries read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackedSeries(
      id: fields[0] as int,
      publicationId: fields[1] as String,
      listId: fields[2] as int,
      currentChapter: fields[3] as int,
      score: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TrackedSeries obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.publicationId)
      ..writeByte(2)
      ..write(obj.listId)
      ..writeByte(3)
      ..write(obj.currentChapter)
      ..writeByte(4)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedSeriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
