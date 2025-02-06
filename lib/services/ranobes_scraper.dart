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

DateTime parseRelativeTime(String relativeTime) {
  final now = DateTime.now();
  final regex =
      RegExp(r'(\d+)\s+(second|minute|hour|day|week|month|year)s?\s+ago');

  final match = regex.firstMatch(relativeTime);
  if (match != null) {
    int value = int.parse(match.group(1)!);
    String unit = match.group(2)!;

    switch (unit) {
      case 'second':
        return now.subtract(Duration(seconds: value));
      case 'minute':
        return now.subtract(Duration(minutes: value));
      case 'hour':
        return now.subtract(Duration(hours: value));
      case 'day':
        return now.subtract(Duration(days: value));
      case 'week':
        return now.subtract(Duration(days: value * 7));
      case 'month':
        return DateTime(now.year, now.month - value, now.day);
      case 'year':
        return DateTime(now.year - value, now.month, now.day);
    }
  }

  return now; // Default fallback if parsing fails
}

String htmlString = "";

Future<List<Publication>> scrapeRaNobesSearch(String query) async {
  Completer<List<Publication>> completer = Completer();
  List<Publication> results = [];

  var headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(
      url: WebUri("https://ranobes.top/search/$query"),
    ),
    onLoadStop: (controller, url) async {
      htmlString = await controller.evaluateJavascript(
          source: "document.documentElement.outerHTML");

      Document document = html_parser.parse(htmlString);
      List<Element> items =
          document.getElementsByClassName('block story shortstory');

      for (var item in items) {
        String? title = item.querySelector('.title')?.text.trim();
        String? url = item.querySelector('.title a')?.attributes['href'];
        String? style = item.querySelector('figure.cover')?.attributes['style'];

        // Extract image URL from 'style' attribute
        String? imageUrl;
        if (style != null) {
          RegExp regExp = RegExp(r'background-image:\s*url\(([^)]+)\)');
          Match? match = regExp.firstMatch(style);
          if (match != null && match.groupCount > 0) {
            imageUrl = match.group(1)?.replaceAll('"', '');
          }
        }

        // Ensure non-null values before adding to the results list
        if (title != null && url != null && imageUrl != null) {
          String publicationId = url.split('/').last;
          String normalizedId = publicationId
              .toLowerCase()
              .replaceAll('-', '_'); // ✅ Standardized

          results.add(
            Publication(
              id: publicationId,
              title: title,
              type: ContentType.Novel,
              url: url,
              thumbnailUrl: imageUrl,
              dateAdded: DateTime.now(),
            ),
          );
        } else {
          log('⚠️ Missing data in HTML element');
        }
      }

      controller.dispose();
      completer.complete(results);
    },
  );

  await headlessWebView.run();
  return completer.future;
}

Future<PublicationDetails> scrapeRaNobesPublicationDetails(String url) async {
  Completer<PublicationDetails> completer = Completer();
  Publication? publication;
  List<Chapter> chapters = [];

  var headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(url)),
    onLoadStop: (controller, url) async {
      String htmlString = await controller.evaluateJavascript(
          source: "document.documentElement.outerHTML");

      Document document = html_parser.parse(htmlString);

      // Extract title without subtitle
      String extractTitle(Element? element) {
        if (element == null) return "Unknown Title";

        // Extract only the first non-span text
        String extractedText = element.nodes
            .whereType<Text>()
            .map((node) => node.text.trim())
            .join(" ")
            .trim(); // Ensure we trim extra spaces

        // ✅ Fallback: If empty or just a space, try grabbing from <span itemprop="name">
        if (extractedText.isEmpty) {
          extractedText =
              element.querySelector('span[itemprop="name"]')?.text.trim() ??
                  "Unknown Title";
        }

        return extractedText;
      }

      String title = extractTitle(document.querySelector('.title'));

      String? author =
          document.querySelector('span[itemprop="creator"] a')?.text.trim();

      //ranobes statuses: Any, Ongoing, Completed, Hiatus, Dropped
      String extractStatus(Document document) {
        // Find all <li> elements
        List<Element> listItems = document.querySelectorAll("ul li");

        for (var item in listItems) {
          // ✅ Check if the <li> contains "Status in COO:"
          if (item.text.contains("Status in COO:")) {
            // ✅ Extract text inside <span class="grey"> inside the <li>
            return item.querySelector("span.grey a")?.text.trim() ??
                "Unknown Status";
          }
        }

        return "Unknown Status"; // Default if not found
      }

      String status = extractStatus(document);

      Element? imageElement = document.querySelector('div.poster a.highslide');
      String? thumbnailUrl = imageElement?.attributes['href'];

      String? description = document.querySelector('.moreless')?.text.trim();

      List<String> extractGenres(Document document) {
        // ✅ Find the "links" div inside the genre section
        Element? genreContainer = document.querySelector('#mc-fs-genre .links');

        if (genreContainer != null) {
          // ✅ Extract text from all <a> elements inside the div
          return genreContainer
              .querySelectorAll('a')
              .map((e) => e.text.trim())
              .toList();
        }

        return []; // Default to empty list if not found
      }

      List<String> genres = extractGenres(document);

      if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
        Element? figureElement = document.querySelector('figure.cover');
        String? style = figureElement?.attributes['style'];

        if (style != null) {
          RegExp regExp = RegExp(r'background-image:\s*url\(([^)]+)\)');
          Match? match = regExp.firstMatch(style);
          if (match != null) {
            thumbnailUrl = match.group(1)?.replaceAll('"', '');
          }
        }
      }

      String publicationId = url.toString().split('/').last;
      String normalizedPublicationId = publicationId
          .toLowerCase()
          .replaceAll('-', '_'); // Standardized format

      publication = Publication(
          id: publicationId,
          title: title,
          author: author,
          status: status,
          thumbnailUrl: thumbnailUrl,
          description: description,
          type: ContentType.Novel,
          dateAdded: DateTime.now(),
          url: url.toString(),
          genres: genres);

      List<Element> chapterElements =
          document.querySelectorAll('.chapters-scroll-list li');
      for (var chapterElement in chapterElements) {
        String? chapterTitle =
            chapterElement.querySelector('.title')?.text.trim();
        String? chapterUrl =
            chapterElement.querySelector('a')?.attributes['href'];
        String? dateUploadedText =
            chapterElement.querySelector('.grey')?.text.trim();
        DateTime? dateUploaded = dateUploadedText != null
            ? parseRelativeTime(dateUploadedText)
            : null;

        if (chapterTitle != null && chapterUrl != null) {
          chapters.add(Chapter(
            id: "$publicationId-$chapterTitle".hashCode, // ✅ Unique chapter ID
            publicationId: -1, // ❌ Dummy value, ignored
            normalizedPublicationId:
                normalizedPublicationId, // ✅ Use this for lookups
            name: chapterTitle,
            url: chapterUrl,
            dateUpload: dateUploaded,
          ));
        }
      }

      controller.dispose();
      completer.complete(
          PublicationDetails(publication: publication!, chapters: chapters));
    },
  );

  await headlessWebView.run();
  return completer.future;
}

Future<ChapterDetails> scrapeRaNobesChapterDetails(
    String url, int publicationId) async {
  Completer<ChapterDetails> completer = Completer();
  Chapter? chapter;
  List<ChapterPage> pages = [];

  var headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(url)),
    onLoadStop: (controller, url) async {
      var currentUrl = url?.toString() ?? "";

      String htmlString = await controller.evaluateJavascript(
          source: "document.documentElement.outerHTML") as String;

      Document document = html_parser.parse(htmlString);

      String? chapterTitle = document.querySelector('h1.title')?.text.trim();

      String formattedText = "";
      List<Element> paragraphs = document.querySelectorAll('#arrticle p');
      for (var paragraph in paragraphs) {
        formattedText += paragraph.text.trim() + "\n\n";
      }

      chapter = Chapter(
        id: currentUrl.hashCode, // Temporary unique ID
        publicationId: publicationId,
        name: chapterTitle ?? "Unknown Chapter",
        url: currentUrl,
        dateUpload:
            DateTime.now(), // Placeholder (actual date parsing can be added)
      );

      if (formattedText.isNotEmpty && chapter != null) {
        pages.add(ChapterPage(
          id: pages.length + 1, // Unique ID for Hive storage
          chapterId:
              chapter!.id, // ✅ Now safe since chapter is confirmed non-null
          pageNo: 1, // Only one page for novels
          finished: false, // Default to unread
          url: currentUrl,
          imageUrl: null, // No images for novels
          text: formattedText, // ✅ Store properly formatted text
        ));
      }

      controller.dispose();
      completer.complete(ChapterDetails(chapter: chapter!, pages: pages));
    },
  );

  await headlessWebView.run();
  return completer.future;
}
