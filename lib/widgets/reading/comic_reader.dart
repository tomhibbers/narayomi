import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/models/chapter_details.dart';

class ComicReader extends StatelessWidget {
  final List<ChapterDetails> loadedChapters;
  final ScrollController scrollController;

  const ComicReader({
    super.key,
    required this.loadedChapters,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (loadedChapters.isEmpty || loadedChapters.first.pages.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: loadedChapters.first.pages.length,
      itemBuilder: (context, index) {
        return Image.network(loadedChapters.first.pages[index].imageUrl!);
      },
    );
  }
}
