import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Import intl package
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/pages/reading_page.dart';
import 'package:narayomi/utils/sorting.dart';

class ChaptersComponent extends StatelessWidget {
  final List<Chapter> chapters;
  final Publication publication;

  const ChaptersComponent(
      {super.key, required this.chapters, required this.publication});

  String formatDate(DateTime? date) {
    if (date == null) return "Unknown Date";
    return DateFormat('yyyy MMM dd').format(date); // ✅ Format as "2024 Nov 14"
  }

  @override
  Widget build(BuildContext context) {
    List<Chapter> sortedChapters =
        List.from(chapters); // ✅ Create a new sorted list
    sortedChapters.sort((a, b) => compareChapterNumbers(
        extractChapterNumber(a.name),
        extractChapterNumber(b.name))); // ✅ Sort descending

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text("Chapters",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: sortedChapters.length,
          itemBuilder: (context, index) {
            final chapter = sortedChapters[index];
            return ListTile(
              title: Text(chapter.name),
              subtitle:
                  Text(formatDate(chapter.dateUpload)), // ✅ Formatted date
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Theme.of(context).colorScheme.onBackground),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingPage(
                      publication: publication, // ✅ Pass the publication
                      chapters: sortedChapters, // ✅ Pass the full chapter list
                      initialIndex:
                          index, // ✅ Set the clicked chapter as initial
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
