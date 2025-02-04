// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublicationAdapter extends TypeAdapter<Publication> {
  @override
  final int typeId = 1;

  @override
  Publication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Publication(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as ContentType,
      url: fields[3] as String?,
      status: fields[4] as String?,
      rating: fields[5] as String?,
      catalogId: fields[6] as int?,
      categories: (fields[7] as List?)?.cast<String>(),
      dateAdded: fields[8] as DateTime?,
      artist: fields[9] as String?,
      author: fields[10] as String?,
      description: fields[11] as String?,
      genres: (fields[12] as List?)?.cast<String>(),
      thumbnailUrl: fields[13] as String?,
      lastModifiedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Publication obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.catalogId)
      ..writeByte(7)
      ..write(obj.categories)
      ..writeByte(8)
      ..write(obj.dateAdded)
      ..writeByte(9)
      ..write(obj.artist)
      ..writeByte(10)
      ..write(obj.author)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.genres)
      ..writeByte(13)
      ..write(obj.thumbnailUrl)
      ..writeByte(14)
      ..write(obj.lastModifiedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
