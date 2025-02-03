import 'package:flutter/material.dart';
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/pages/reading_page.dart';

class ChaptersComponent extends StatelessWidget {
  final List<Chapter> chapters;

  const ChaptersComponent({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
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
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ListTile(
              title: Text(chapter.name),
              subtitle: Text("Uploaded: ${chapter.dateUpload?.toLocal()}"),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingPage(
                      chapters: chapters, // ✅ Pass the full chapter list
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
