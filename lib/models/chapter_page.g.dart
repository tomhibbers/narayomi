// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_page.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterPageAdapter extends TypeAdapter<ChapterPage> {
  @override
  final int typeId = 3;

  @override
  ChapterPage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterPage(
      id: fields[0] as int,
      chapterId: fields[1] as int,
      pageNo: fields[2] as int,
      finished: fields[3] as bool,
      url: fields[4] as String,
      imageUrl: fields[5] as String?,
      text: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterPage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chapterId)
      ..writeByte(2)
      ..write(obj.pageNo)
      ..writeByte(3)
      ..write(obj.finished)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterPageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
