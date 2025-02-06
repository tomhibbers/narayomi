// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final int typeId = 2;

  @override
  Chapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chapter(
      id: fields[0] as int,
      publicationId: fields[1] as int,
      normalizedPublicationId: fields[13] as String?,
      url: fields[2] as String,
      name: fields[3] as String,
      dateUpload: fields[4] as DateTime?,
      chapterNumber: fields[5] as double,
      scanlator: fields[6] as String?,
      read: fields[7] as bool,
      downloaded: fields[8] as bool,
      bookmark: fields[9] as bool,
      lastPageRead: fields[10] as int,
      dateFetch: fields[11] as DateTime?,
      lastModified: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.publicationId)
      ..writeByte(13)
      ..write(obj.normalizedPublicationId)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.dateUpload)
      ..writeByte(5)
      ..write(obj.chapterNumber)
      ..writeByte(6)
      ..write(obj.scanlator)
      ..writeByte(7)
      ..write(obj.read)
      ..writeByte(8)
      ..write(obj.downloaded)
      ..writeByte(9)
      ..write(obj.bookmark)
      ..writeByte(10)
      ..write(obj.lastPageRead)
      ..writeByte(11)
      ..write(obj.dateFetch)
      ..writeByte(12)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
