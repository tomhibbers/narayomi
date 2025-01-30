// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogAdapter extends TypeAdapter<Catalog> {
  @override
  final int typeId = 0;

  @override
  Catalog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Catalog(
      index: fields[0] as int?,
      hasVolumeInfos: fields[1] as bool?,
      name: fields[2] as String?,
      catalogName: fields[3] as String?,
      baseUrl: fields[4] as String?,
      lang: fields[5] as String?,
      type: fields[6] as ContentType,
      typeId: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Catalog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.index)
      ..writeByte(1)
      ..write(obj.hasVolumeInfos)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.catalogName)
      ..writeByte(4)
      ..write(obj.baseUrl)
      ..writeByte(5)
      ..write(obj.lang)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.typeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
