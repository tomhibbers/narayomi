import 'package:hive/hive.dart';

part 'chapter_page.g.dart';

@HiveType(typeId: 3)
class ChapterPage extends HiveObject {
  @HiveField(0) int id;
  @HiveField(1) int chapterId;
  @HiveField(2) int pageNo;
  @HiveField(3) bool finished;
  @HiveField(4) String url;
  @HiveField(5) String? imageUrl;
  @HiveField(6) String? text;

  ChapterPage({
    required this.id,
    required this.chapterId,
    required this.pageNo,
    this.finished = false,
    required this.url,
    this.imageUrl,
    this.text,
  });
}
