import 'package:hive/hive.dart';
import 'content_type.dart';

part 'catalog.g.dart';

@HiveType(typeId: 0)
class Catalog extends HiveObject {
  @HiveField(0) int? index;
  @HiveField(1) bool? hasVolumeInfos;
  @HiveField(2) String? name;
  @HiveField(3) String? catalogName;
  @HiveField(4) String? baseUrl;
  @HiveField(5) String? lang;
  @HiveField(6) ContentType type;
  @HiveField(7) int typeId;

  Catalog({
    this.index,
    this.hasVolumeInfos,
    this.name,
    this.catalogName,
    this.baseUrl,
    this.lang,
    required this.type,
    required this.typeId,
  });
}
