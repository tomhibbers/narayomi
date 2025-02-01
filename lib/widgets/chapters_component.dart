import 'package:flutter/material.dart';
import '../models/chapter.dart';

class ChaptersComponent extends StatelessWidget {
  final List<Chapter> chapters;

  const ChaptersComponent({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: chapters.isEmpty
          ? Center(child: Text("No chapters available"))
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];

                return ListTile(
                  title: Text(chapter.name),
                  subtitle: Text(
                    chapter.dateUpload != null
                        ? "Uploaded: ${chapter.dateUpload!.toLocal()}"
                        : "Unknown Date",
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () {
                    // TODO: Implement navigation to the Reader Page
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening ${chapter.name}...")),
                    );
                  },
                );
              },
            ),
    );
  }
}
