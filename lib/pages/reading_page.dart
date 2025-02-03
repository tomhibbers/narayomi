import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/chapter_details.dart';
import 'package:narayomi/services/ranobes_scraper.dart';
import 'package:narayomi/widgets/reading/reading_top_bar.dart';
import 'package:narayomi/widgets/reading/reading_bottom_bar.dart';
import 'package:narayomi/widgets/reading/reading_scroll_indicator.dart';

class ReadingPage extends StatefulWidget {
  final Chapter chapter;

  const ReadingPage({super.key, required this.chapter});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  ChapterDetails? chapterDetails;
  bool isLoading = true;
  bool isUIVisible = false; // ✅ UI starts hidden
  double scrollProgress = 0.0; // ✅ Scroll position (0 = top, 1 = bottom)

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchChapterContent();
    _scrollController.addListener(_updateScrollProgress);
  }

  Future<void> _fetchChapterContent() async {
    log("📖 Fetching chapter content for: ${widget.chapter.name}");

    ChapterDetails details = await scrapeChapterDetails(widget.chapter.url, widget.chapter.publicationId);

    setState(() {
      chapterDetails = details;
      isLoading = false;
    });
  }

  void _toggleUI() {
    setState(() {
      isUIVisible = !isUIVisible;
    });
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      setState(() {
        scrollProgress = (maxScroll == 0) ? 0 : currentScroll / maxScroll;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ✅ Dark background for reading mode
      body: Stack(
        children: [
          // ✅ Chapter Content
          GestureDetector(
            onTap: _toggleUI, // ✅ Tap to show/hide UI
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : SingleChildScrollView(
                      controller: _scrollController, // ✅ Track scrolling
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        chapterDetails?.pages.first.text ?? "No content available",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ),
          ),

          // ✅ Use Components
          ReadingScrollIndicator(scrollProgress: scrollProgress),
          ReadingTopBar(title: widget.chapter.name, isVisible: isUIVisible),
          ReadingBottomBar(isVisible: isUIVisible),
        ],
      ),
    );
  }
}
