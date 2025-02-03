import 'package:narayomi/models/chapter_page.dart';

import 'chapter.dart';

class ChapterDetails {
  final Chapter chapter;
  final List<ChapterPage> pages;

  ChapterDetails({required this.chapter, required this.pages});
}