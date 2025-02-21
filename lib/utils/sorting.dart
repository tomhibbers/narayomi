import 'dart:developer';

import 'package:narayomi/models/chapter.dart';

List<Chapter> sortChaptersByTitle(List<Chapter> chapters) {
  chapters.sort((a, b) {
    List<int> numA = extractChapterNumber(a.name);
    List<int> numB = extractChapterNumber(b.name);
    return compareChapterNumbers(numB, numA); // ✅ Descending order
  });

  log("📌 Sorted Chapters: ${chapters.map((c) => c.name).join(' | ')}");
  return chapters;
}

// ✅ Extracts chapter numbers as a list of integers
List<int> extractChapterNumber(String title) {
  RegExp regex = RegExp(r'(\d+(?:\.\d+)*)'); // ✅ Matches "10", "1.1.1", "2.2"
  Match? match = regex.firstMatch(title);

  if (match != null) {
    return match.group(1)!.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }
  return [0]; // ✅ Default to 0 if no number found
}

// ✅ Compares multi-part chapter numbers correctly
int compareChapterNumbers(List<int> a, List<int> b) {
  for (int i = 0; i < a.length || i < b.length; i++) {
    int numA = (i < a.length) ? a[i] : 0;
    int numB = (i < b.length) ? b[i] : 0;
    if (numA != numB) return numB.compareTo(numA); // ✅ Descending order
  }
  return 0;
}
