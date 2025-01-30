// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentTypeAdapter extends TypeAdapter<ContentType> {
  @override
  final int typeId = 4;

  @override
  ContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContentType.Comic;
      case 1:
        return ContentType.Novel;
      default:
        return ContentType.Comic;
    }
  }

  @override
  void write(BinaryWriter writer, ContentType obj) {
    switch (obj) {
      case ContentType.Comic:
        writer.writeByte(0);
        break;
      case ContentType.Novel:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
