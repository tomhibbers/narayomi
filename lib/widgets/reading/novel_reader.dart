import 'package:flutter/material.dart';
import 'package:narayomi/models/chapter_details.dart';

class NovelReader extends StatelessWidget {
  final List<ChapterDetails> loadedChapters;
  final ScrollController scrollController;

  const NovelReader({
    super.key,
    required this.loadedChapters,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.0),
      itemCount: loadedChapters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 32.0),
          child: Text(
            loadedChapters[index].pages.first.text ?? "No content available",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        );
      },
    );
  }
}
