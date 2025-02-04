import 'package:flutter/material.dart';
import 'package:narayomi/pages/webview_page.dart';
import 'package:narayomi/models/chapter.dart';

class ReadingBottomBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool hasPrevious;
  final bool hasNext;
  final ScrollController scrollController;
  final Chapter chapter; // ✅ Pass the current chapter

  const ReadingBottomBar({
    super.key,
    required this.isVisible,
    required this.onPrevious,
    required this.onNext,
    required this.hasPrevious,
    required this.hasNext,
    required this.scrollController,
    required this.chapter, // ✅ Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: isVisible ? 0 : -60,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                  color: hasPrevious ? Colors.white : Colors.grey),
              onPressed: hasPrevious
                  ? () {
                      onPrevious();
                      scrollController.jumpTo(0); // ✅ Properly resets scrollbar
                    }
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () {}, // Placeholder for chapter list
            ),
            IconButton(
              icon: Icon(Icons.public_outlined, color: Colors.white),
              onPressed: () {
                if (chapter.url.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(
                        url: chapter.url,
                        publicationTitle: chapter.name,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No webpage available")),
                  );
                }
              }, // ✅ Open WebView with chapter URL
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {}, // Placeholder for reader settings
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward,
                  color: hasNext ? Colors.white : Colors.grey),
              onPressed: hasNext
                  ? () {
                      onNext();
                      scrollController.jumpTo(0); // ✅ Properly resets scrollbar
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
