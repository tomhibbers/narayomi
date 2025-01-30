import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 2)
class Chapter extends HiveObject {
  @HiveField(0) int id;
  @HiveField(1) int publicationId;
  @HiveField(2) String url;
  @HiveField(3) String name;
  @HiveField(4) DateTime? dateUpload;
  @HiveField(5) double chapterNumber;
  @HiveField(6) String? scanlator;
  @HiveField(7) bool read;
  @HiveField(8) bool downloaded;
  @HiveField(9) bool bookmark;
  @HiveField(10) int lastPageRead;
  @HiveField(11) DateTime? dateFetch;
  @HiveField(12) DateTime? lastModified;

  Chapter({
    required this.id,
    required this.publicationId,
    required this.url,
    required this.name,
    this.dateUpload,
    this.chapterNumber = 0.0,
    this.scanlator,
    this.read = false,
    this.downloaded = false,
    this.bookmark = false,
    this.lastPageRead = 0,
    this.dateFetch,
    this.lastModified,
  });
}
