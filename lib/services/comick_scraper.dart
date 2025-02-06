import 'dart:async';
import 'dart:developer';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/chapter_details.dart';
import 'package:narayomi/models/chapter_page.dart';
import 'package:narayomi/models/publication_details.dart';
import '../models/publication.dart';
import '../models/content_type.dart';

String htmlString = ""; // ✅ Store for debugging

Future<List<Publication>> scrapeComickSearch(String query) async {
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
                results.add(
                  Publication(
                    id: url.split('/').last,
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

Future<PublicationDetails> scrapeComickPublicationDetails(String url) async {
  Completer<PublicationDetails> completer = Completer();
  Publication? publication;
  List<Chapter> chapters = [];
  bool _isDisposed = false;

  var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onLoadStop: (controller, url) async {
        var currentUrl = url?.toString() ?? "";
        if (_isDisposed) return;

        try {
          await Future.delayed(Duration(seconds: 2)); // Shorter wait

          int previousCount = 0;
          int retries = 0;
          const int maxRetries = 3; // ✅ Lower retries (faster)

          while (retries < maxRetries) {
            // ✅ Get HTML source
            htmlString = await controller.evaluateJavascript(
                source: "document.documentElement.outerHTML");
            Document document = html_parser.parse(htmlString);

            // ✅ Count current chapters loaded
            List<Element> chapterElements =
                document.querySelectorAll('td.customclass1');

            if (chapterElements.length > previousCount) {
              retries = 0; // ✅ Reset retries if new content is loaded
            } else {
              retries++; // ✅ Increase retries only if no new content loaded
            }

            previousCount = chapterElements.length;

            // ✅ Break early if a lot of chapters already loaded
            if (previousCount > 50)
              break; // 🔥 Adjust this threshold based on testing

            // ✅ Scroll down in bigger steps for faster loading
            await controller.evaluateJavascript(source: """
          window.scrollBy(0, window.innerHeight * 2);
        """);

            await Future.delayed(
                Duration(seconds: 1)); // ✅ Shorter wait per scroll
          }

          Document document = html_parser.parse(htmlString);

          // ✅ Extract Title
          String title = document
                  .querySelector(
                      'h1.md\\:hidden.col-span-3.break-words.max-md\\:mb-4')
                  ?.text
                  .trim() ??
              "Unknown Title";

          String? thumbnailUrl = document
              .querySelector('div.mr-4.relative.row-span-5 img')
              ?.attributes['src']
              ?.trim();

          String? author = document
              .querySelectorAll('tr') // Get all table rows
              .firstWhere(
                (row) => row.text.contains("Authors:"), // Find the correct row
                orElse: () => Element.tag('tr'),
              )
              .querySelector('td.pl-2 a.link')
              ?.text
              .trim();

          // ✅ Extract Genres
          List<String> genres = document
              .querySelectorAll('tr') // Get all table rows
              .firstWhere(
                (row) => row.text.contains("Genres:"), // Find the correct row
                orElse: () => Element.tag('tr'),
              )
              .querySelectorAll('td.pl-2 a.link') // Get all links in that row
              .map((e) => e.text.trim()) // Extract text
              .toList();

          String? description =
              document.querySelector('div.comic-desc p')?.text.trim();

          // ✅ Find all div elements
          List<Element> divs = document.querySelectorAll('div');

          // ✅ Locate the specific div that contains "Translation:"
          Element? translationDiv = divs.firstWhere(
            (div) =>
                div.querySelector('span.text-gray-500')?.text.trim() ==
                "Translation:",
            orElse: () => Element.tag("div"), // Prevents null errors
          );

          // ✅ Extract status text from the span that follows
          String? status = translationDiv?.children
              .where((e) =>
                  e.localName == 'span' && !e.classes.contains('text-gray-500'))
              .map((e) => e.text.trim())
              .join(" "); // Combine if multiple spans (though unlikely)

          // ✅ Clean the extracted text
          status = status?.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();

          // ✅ Create publication object
          publication = Publication(
            id: currentUrl.split('/').last,
            title: title,
            author: author,
            description: description,
            genres: genres,
            status: status,
            type: ContentType.Comic,
            url: currentUrl,
            thumbnailUrl: thumbnailUrl,
            dateAdded: DateTime.now(),
          );

          // ✅ Select all chapter rows
          List<Element> chapterElements =
              document.querySelectorAll('td.customclass1');

          for (var chapterElement in chapterElements) {
            // ✅ Extract URL
            String? chapterUrl =
                chapterElement.querySelector('a')?.attributes['href'];

            // ✅ Extract Main Chapter Title (e.g., "Ch. 51")
            String? chapterNumber =
                chapterElement.querySelector('span.font-semibold')?.text.trim();

            // ✅ Extract Subtitle (if exists, e.g., "Hedgehog Hunting (5)")
            String? chapterSubtitle = chapterElement
                .querySelector('span.text-xs.md\\:text-base')
                ?.text
                .trim();

            // ✅ Combine title & subtitle
            String chapterTitle = chapterNumber ?? "Unknown Chapter";
            if (chapterSubtitle != null && chapterSubtitle.isNotEmpty) {
              chapterTitle += " - $chapterSubtitle";
            }

            // ✅ Add to Chapter List
            if (chapterUrl != null) {
              chapters.add(Chapter(
                id: chapters.length + 1, // Temporary ID
                publicationId: publication!.id.hashCode, // Ensures unique ID
                name: chapterTitle,
                url: "https://comick.io$chapterUrl", // Append base URL
                dateUpload: null, // ✅ Date extraction can be added later
              ));
            }
          }
        } catch (e) {
          log("❌ Error during scraping: $e");
        } finally {
          if (!_isDisposed) {
            _isDisposed = true;
            controller.dispose();
          }
          if (!completer.isCompleted) {
            completer.complete(PublicationDetails(
                publication: publication!, chapters: chapters));
          }
        }
      });

  await headlessWebView.run();
  return completer.future;
}

Future<ChapterDetails> scrapeComickChapterDetails(
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
