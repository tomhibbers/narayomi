import 'dart:async';
import 'dart:developer';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/chapter_details.dart';
import 'package:narayomi/models/chapter_page.dart';
import 'package:narayomi/models/publication_details.dart';
import 'package:narayomi/utils/sorting.dart';
import '../models/publication.dart';
import '../models/content_type.dart';

String htmlString = ""; // ✅ Store for debugging

Future<List<Publication>> comickSearch(String query) async {
  Completer<List<Publication>> completer = Completer();
  List<Publication> results = [];
  bool _isDisposed = false; // ✅ Prevents multiple disposals

  var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri("https://comick.io/search?limit=49&q=${query}"),
      ),
      onLoadStop: (controller, url) async {
        if (_isDisposed) return; // ✅ Skip if already disposed
        try {
          await Future.delayed(
              Duration(seconds: 3)); // ✅ Wait for JavaScript execution

          int previousCount = 0;
          int retries = 0;
          const int maxRetries = 5; // ✅ Prevent infinite loops

          while (true) {
            // ✅ Get HTML source
            String htmlString = await controller.evaluateJavascript(
                source: "document.documentElement.outerHTML");

            Document document = html_parser.parse(htmlString);

            // ✅ Select all publication containers
            List<Element> publicationElements = document.querySelectorAll(
                'div.cursor-pointer.hover\\:bg-gray-100.dark\\:hover\\:bg-gray-700');

            if (publicationElements.length == previousCount) {
              retries++;
              if (retries >= maxRetries)
                break; // ✅ Stop if no new items after max retries
            } else {
              retries = 0; // ✅ Reset retries when new data is found
            }

            previousCount = publicationElements.length;

            for (var element in publicationElements) {
              // ✅ Extract Title
              String? title =
                  element.querySelector('p.font-bold.truncate')?.text.trim();

              // ✅ Extract URL
              String? url = element
                  .querySelector('a.block.h-16.md\\:h-24')
                  ?.attributes['href']
                  ?.trim();

              // ✅ Extract Thumbnail URL
              String? thumbnailUrl = element
                  .querySelector('img.select-none.rounded-md.object-cover')
                  ?.attributes['src'];

              if (title != null && url != null && thumbnailUrl != null) {
                String publicationId = url.split('/').last;
                String normalizedId = publicationId
                    .toLowerCase()
                    .replaceAll('-', '_'); // ✅ Standardized

                results.add(
                  Publication(
                    id: publicationId,
                    title: title,
                    type: ContentType.Comic,
                    url: 'https://comick.io${url}',
                    thumbnailUrl: thumbnailUrl,
                    dateAdded: DateTime.now(),
                  ),
                );
              } else {
                log('⚠️ Missing data in HTML element');
              }
            }

            // ✅ Scroll down to trigger lazy loading
            await controller.evaluateJavascript(source: """
            window.scrollBy(0, document.body.scrollHeight);
          """);

            await Future.delayed(
                Duration(seconds: 2)); // ✅ Allow time for new items to load
          }

          if (results.isEmpty) {
            log("⚠️ No search results found - JavaScript might not have executed fully.");
          }
        } catch (e) {
          log("❌ Error during scraping: $e");
        } finally {
          if (!_isDisposed) {
            _isDisposed = true; // ✅ Ensure disposal only happens once
            controller.dispose(); // ✅ Now safe to dispose
          }
          if (!completer.isCompleted) completer.complete(results);
        }
      });

  await headlessWebView.run();
  return completer.future;
}

Future<PublicationDetails> comickPublicationDetails(
    String url, void Function(String) showToast) async {
  Completer<PublicationDetails> completer = Completer();
  Publication? publication;
  List<Chapter> allChapters = [];

  int page = 1;
  bool hasMorePages = true;

  // ✅ Call toast function without needing `context`
  showToast("Fetching chapters, please wait...");

  try {
    while (hasMorePages) {
      int prevChapterCount = allChapters.length;
      log("📢 Fetching page $page...");
      Publication? pagePublication =
          await fetchChaptersForPage(url, page, allChapters);

      if (page == 1 && pagePublication != null) {
        publication = pagePublication;
      }

      if (allChapters.length == prevChapterCount) {
        hasMorePages = false;
      } else {
        page++;
      }
    }

    if (publication == null) {
      throw Exception("Failed to retrieve publication details.");
    }

    allChapters = sortChaptersByTitle(allChapters);

    // ✅ Call toast function
    showToast("Found ${allChapters.length} chapters!");

    completer.complete(
        PublicationDetails(publication: publication, chapters: allChapters));
  } catch (e) {
    log("❌ Error fetching publication details: $e");
    showToast("Error: Failed to fetch chapters.");
    completer.completeError(e);
  }

  return completer.future;
}

Future<Publication?> fetchChaptersForPage(
    String baseUrl, int page, List<Chapter> allChapters) async {
  Completer<void> completer = Completer();
  bool _isDisposed = false;

  Publication? publication;

  var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri("$baseUrl?page=$page&lang=en")),
      onLoadStop: (controller, url) async {
        if (_isDisposed) return;

        try {
          log("📢 Loading page $page...");
          await Future.delayed(Duration(seconds: 3)); // ✅ Ensure full page load

          int retries = 0;
          const int maxRetries = 5;

          while (retries < maxRetries) {
            String htmlString = await controller.evaluateJavascript(
                source: "document.documentElement.outerHTML");
            Document document = html_parser.parse(htmlString);

            List<Element> chapterElements =
                document.querySelectorAll('td.customclass1');

            if (chapterElements.isNotEmpty) {
              log("✅ Found ${chapterElements.length} chapters on page $page.");
              break; // ✅ Exit loop once content is loaded
            }

            log("🔄 Retry $retries: Waiting for chapters...");
            retries++;
            await Future.delayed(Duration(seconds: 2));
          }

          if (retries == maxRetries) {
            log("⚠️ No chapters found on page $page. Possibly last page.");
            completer.complete();
            return;
          }

          log("exit fetchChaptersForPage while loop");

          String publicationId = baseUrl.split('/').last;
          String normalizedPublicationId =
              publicationId.toLowerCase().replaceAll('-', '_');

          Document document = html_parser.parse(
              await controller.evaluateJavascript(
                  source: "document.documentElement.outerHTML"));

          // ✅ Extract publication info (only for page 1)
          if (page == 1) {
            String? extractedTitle = document.querySelector('h1')?.text.trim();

            if (extractedTitle == null || extractedTitle.isEmpty) {
              log("⚠️ Publication title could not be extracted.");
              throw Exception("Failed to retrieve publication details.");
            }

            log("✅ Extracted publication title: $extractedTitle");
            publication = Publication(
              id: publicationId,
              title: extractedTitle,
              author: document
                  .querySelectorAll('tr')
                  .firstWhere((row) => row.text.contains("Authors:"),
                      orElse: () => Element.tag('tr'))
                  .querySelector('td.pl-2 a.link')
                  ?.text
                  .trim(),
              description:
                  document.querySelector('div.comic-desc p')?.text.trim(),
              genres: document
                  .querySelectorAll('tr')
                  .firstWhere((row) => row.text.contains("Genres:"),
                      orElse: () => Element.tag('tr'))
                  .querySelectorAll('td.pl-2 a.link')
                  .map((e) => e.text.trim())
                  .toList(),
              status: "Ongoing",
              type: ContentType.Comic,
              url: baseUrl,
              thumbnailUrl: document
                  .querySelector('div.mr-4.relative.row-span-5 img')
                  ?.attributes['src']
                  ?.trim(),
              dateAdded: DateTime.now(),
            );
          }

          // ✅ Extract chapters
          for (var chapterElement
              in document.querySelectorAll('td.customclass1')) {
            String? chapterUrl =
                chapterElement.querySelector('a')?.attributes['href'];
            String? chapterNumber =
                chapterElement.querySelector('span.font-semibold')?.text.trim();
            String? chapterSubtitle = chapterElement
                .querySelector('span.text-xs.md\\:text-base')
                ?.text
                .trim();
            String chapterTitle = chapterNumber ?? "Unknown Chapter";

            if (chapterSubtitle != null && chapterSubtitle.isNotEmpty) {
              chapterTitle += " - $chapterSubtitle";
            }

            if (chapterUrl != null) {
              allChapters.add(Chapter(
                id: "$publicationId-$chapterTitle"
                    .hashCode, // ✅ Unique chapter ID
                publicationId: -1, // ❌ Dummy value, ignored
                normalizedPublicationId:
                    normalizedPublicationId, // ✅ Correct format
                name: chapterTitle,
                url: "https://comick.io$chapterUrl", // Append base URL
                dateUpload: null, // ✅ Date extraction can be added later
              ));
            }
          }

          log("✅ Finished scraping page $page");
          completer.complete();
        } catch (e) {
          log("❌ Error during scraping page $page: $e");
          completer.completeError(e);
        }
      });

  await headlessWebView.run();
  await completer.future; // ✅ Ensure function waits

  // ✅ Dispose WebView only after work is complete
  if (!_isDisposed) {
    _isDisposed = true;
    log("🛑 Disposing WebView for page $page");
    headlessWebView.dispose();
  }

  return publication; // ✅ Only returns non-null on page 1
}

Future<ChapterDetails> comickChapterDetails(
    String url, int publicationId) async {
  Completer<ChapterDetails> completer = Completer();

  Chapter chapter = Chapter(
    id: publicationId,
    publicationId: publicationId,
    name: "Unknown Chapter",
    url: url,
    dateUpload: DateTime.now(),
  );

  List<ChapterPage> pages = [];
  bool _isDisposed = false;
  Set<String> uniqueUrls = {}; // ✅ Keep track of unique image URLs

  var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onLoadStop: (controller, url) async {
        var currentUrl = url?.toString() ?? "";
        if (_isDisposed) return;

        try {
          await Future.delayed(Duration(seconds: 2));

          int retries = 0;
          const int maxRetries = 3;

          while (retries < maxRetries) {
            // ✅ Get HTML source
            htmlString = await controller.evaluateJavascript(
                source: "document.documentElement.outerHTML");
            Document document = html_parser.parse(htmlString);

            // ✅ Select all page elements
            List<Element> pageElements =
                document.querySelectorAll('#images-reader-container > div');

            int pageNo = 1;
            int newPages = 0; // ✅ Track number of new pages added

            for (var element in pageElements) {
              String? imageUrl =
                  element.querySelector('img')?.attributes['src'];

              if (imageUrl != null && !uniqueUrls.contains(imageUrl)) {
                uniqueUrls.add(imageUrl); // ✅ Store unique URLs

                pages.add(ChapterPage(
                  id: pageNo,
                  chapterId: publicationId,
                  pageNo: pageNo,
                  finished: false,
                  url: currentUrl,
                  imageUrl: imageUrl,
                  text: "page$pageNo",
                ));
                pageNo++;
                newPages++; // ✅ Count new pages added
              }
            }

            // ✅ Stop scrolling if no new pages were found
            if (newPages == 0) {
              retries++;
            } else {
              retries = 0; // ✅ Reset retries if new data found
            }

            // ✅ Scroll down for more images
            await controller.evaluateJavascript(source: """
            window.scrollBy(0, window.innerHeight * 2);
            """);

            await Future.delayed(Duration(seconds: 1));
          }
        } catch (e) {
          log("❌ Error during scraping: $e");
        } finally {
          if (!_isDisposed) {
            _isDisposed = true;
            controller.dispose();
          }

          if (!completer.isCompleted) {
            completer.complete(ChapterDetails(chapter: chapter, pages: pages));
          } else {
            log("⚠️ Completer already completed, skipping duplicate call.");
          }
        }
      });

  await headlessWebView.run();
  return completer.future;
}
