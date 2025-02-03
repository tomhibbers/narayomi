import 'package:flutter/material.dart';

class ReadingBottomBar extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool hasPrevious;
  final bool hasNext;
  final ScrollController scrollController;

  const ReadingBottomBar({
    super.key,
    required this.isVisible,
    required this.onPrevious,
    required this.onNext,
    required this.hasPrevious,
    required this.hasNext,
    required this.scrollController,
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
              icon: Icon(Icons.language, color: Colors.white),
              onPressed: () {}, // Placeholder for webview
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
