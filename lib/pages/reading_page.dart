import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/chapter_details.dart';
import 'package:narayomi/services/ranobes_scraper.dart';
import 'package:narayomi/widgets/reading/reading_top_bar.dart';
import 'package:narayomi/widgets/reading/reading_bottom_bar.dart';
import 'package:narayomi/widgets/reading/reading_scroll_indicator.dart';

class ReadingPage extends StatefulWidget {
  final List<Chapter> chapters;
  final int initialIndex;

  const ReadingPage(
      {super.key, required this.chapters, required this.initialIndex});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  List<ChapterDetails> loadedChapters = [];
  bool isLoading = true;
  bool isUIVisible = false;
  double scrollProgress = 0.0;
  late int currentChapterIndex;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    currentChapterIndex = widget.initialIndex;
    _fetchChapter(widget.chapters[currentChapterIndex]);

    // ✅ Attach scroll listener
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.hasClients) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;

      double newProgress = (maxScroll == 0) ? 0 : currentScroll / maxScroll;

      log("📜 SCROLLING: current = $currentScroll, max = $maxScroll, progress = $newProgress");

      setState(() {
        scrollProgress =
            newProgress.clamp(0.0, 1.0); // ✅ Keep within valid range
      });
    }
  }

  Future<void> _fetchChapter(Chapter chapter) async {
    log("📖 Fetching chapter content for: ${chapter.name}");

    setState(() => isLoading = true);
    ChapterDetails details =
        await scrapeChapterDetails(chapter.url, chapter.publicationId);

    setState(() {
      loadedChapters = [details]; // Replace current chapter data
      isLoading = false;
    });
  }

  void _toggleUI() {
    setState(() => isUIVisible = !isUIVisible);
  }

  void _loadPreviousChapter() {
    if (currentChapterIndex + 1 < widget.chapters.length) {
      setState(() {
        currentChapterIndex += 1;
        _fetchChapter(widget.chapters[currentChapterIndex]);
      });
    }
  }

  void _loadNextChapter() {
    if (currentChapterIndex - 1 >= 0) {
      setState(() {
        currentChapterIndex -= 1;
        _fetchChapter(widget.chapters[currentChapterIndex]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleUI,
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.0),
                      itemCount: loadedChapters.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 32.0),
                          child: Text(
                            loadedChapters[index].pages.first.text ??
                                "No content available",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // ✅ UI Components
          ReadingScrollIndicator(scrollProgress: scrollProgress),
          ReadingTopBar(
              title: widget.chapters[currentChapterIndex].name,
              isVisible: isUIVisible),
          ReadingBottomBar(
            isVisible: isUIVisible,
            onPrevious: _loadPreviousChapter,
            onNext: _loadNextChapter,
            hasPrevious: currentChapterIndex + 1 < widget.chapters.length,
            hasNext: currentChapterIndex - 1 >= 0,
            scrollController: _scrollController, // ✅ Pass scrollController
            chapter: widget.chapters[currentChapterIndex],
          ),
        ],
      ),
    );
  }
}
