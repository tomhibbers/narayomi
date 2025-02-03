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

Future<List<Publication>> scrapeRaNobesInBackgroundSearch(String query) async {
  Completer<List<Publication>> completer = Completer();
  List<Publication> results = [];

  var headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(
      url: WebUri("https://ranobes.top/search/$query"),
    ),
    onLoadStop: (controller, url) async {
      log('✅ onLoadStop triggered');
      htmlString = await controller.evaluateJavascript(
          source: "document.documentElement.outerHTML");

      Document document = html_parser.parse(htmlString);
      List<Element> items =
          document.getElementsByClassName('block story shortstory');
      log("✅ Found ${items.length} search results");

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
          results.add(
            Publication(
              id: url.split('/').last,
              title: title,
              type: ContentType.Novel, // ✅ Assuming it's a novel
              typeId: 1,
              url: url,
              thumbnailUrl: imageUrl,
              dateAdded: DateTime.now(),
            ),
          );
        } else {
          log('⚠️ Missing data in HTML element');
        }
      }

      // ✅ Dispose WebView BEFORE completing the future
      controller.dispose();
      completer.complete(results);
    },
  );

  await headlessWebView.run();
  return completer.future; // ✅ Ensures function waits until scraping is done
}

Future<PublicationDetails> scrapePublicationDetails(String url) async {
  Completer<PublicationDetails> completer = Completer();
  Publication? publication;
  List<Chapter> chapters = [];

  var headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(url)),
    onLoadStop: (controller, url) async {
      log('✅ onLoadStop triggered');
      String htmlString = await controller.evaluateJavascript(
          source: "document.documentElement.outerHTML");

      Document document = html_parser.parse(htmlString);
      // final doc = HtmlXPath.html(htmlString);

      String title =
          document.querySelector('.title')?.text.trim() ??
              "Unknown Title";
      String? author =
          document.querySelector('span[itemprop="creator"] a')?.text.trim();
      String? status = document.querySelector('.test')?.text.trim();
      // ✅ Try getting image from <a class="highslide">
      Element? imageElement = document.querySelector('div.poster a.highslide');
      String? thumbnailUrl = imageElement?.attributes['href'];

      String? description = document.querySelector('.moreless')?.text.trim();

      // ✅ If <a> doesn't contain the image, fallback to <figure>'s background-image
      if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
        Element? figureElement = document.querySelector('figure.cover');
        String? style = figureElement?.attributes['style'];

        // Extract the URL from the style attribute
        if (style != null) {
          RegExp regExp = RegExp(r'background-image:\s*url\(([^)]+)\)');
          Match? match = regExp.firstMatch(style);
          if (match != null) {
            thumbnailUrl = match.group(1)?.replaceAll('"', '');
          }
        }
      }

      publication = Publication(
        id: url.toString().split('/').last,
        title: title,
        author: author,
        status: status,
        thumbnailUrl: thumbnailUrl,
        description: description,
        type: ContentType.Novel, // Assume novel for now
        typeId: 1,
        dateAdded: DateTime.now(),
      );

      // ✅ Extract list of chapters
      List<Element> chapterElements =
          document.querySelectorAll('.chapters-scroll-list li');
      for (var chapterElement in chapterElements) {
        String? chapterTitle =
            chapterElement.querySelector('.title')?.text.trim();
        String? chapterUrl =
            chapterElement.querySelector('a')?.attributes['href'];
        String? dateUploaded =
            chapterElement.querySelector('.chapter-date')?.text.trim();

        if (chapterTitle != null && chapterUrl != null) {
          chapters.add(Chapter(
            id: chapters.length + 1, // Temporary ID
            publicationId: publication!.id.hashCode, // Temporary unique ID
            name: chapterTitle,
            url: chapterUrl,
            dateUpload:
                dateUploaded != null ? DateTime.tryParse(dateUploaded) : null,
          ));
        }
      }

      // ✅ Dispose WebView & complete future
      controller.dispose();
      completer.complete(
          PublicationDetails(publication: publication!, chapters: chapters));
    },
  );

  await headlessWebView.run();
  return completer.future;
}

Future<ChapterDetails> scrapeChapterDetails(String url, int publicationId) async {
  Completer<ChapterDetails> completer = Completer();
  Chapter? chapter;
  List<ChapterPage> pages = [];

  var headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(url)),
    onLoadStop: (controller, url) async {
      log('✅ onLoadStop triggered for chapter: $url');

      // ✅ Convert WebUri? to String
      var currentUrl = url?.toString() ?? "";

      // ✅ Get the full HTML source
      String htmlString = await controller.evaluateJavascript(
          source: "document.documentElement.outerHTML"
      ) as String;

      Document document = html_parser.parse(htmlString);

      // ✅ Extract Chapter Title
      String? chapterTitle = document.querySelector('h1.title')?.text.trim();

      // ✅ Extract Chapter Content with Paragraph Formatting
      String formattedText = "";
      List<Element> paragraphs = document.querySelectorAll('#arrticle p');
      for (var paragraph in paragraphs) {
        formattedText += paragraph.text.trim() + "\n\n"; // ✅ Add double line breaks for readability
      }

      // ✅ Create Chapter Model
      chapter = Chapter(
        id: currentUrl.hashCode, // Temporary unique ID
        publicationId: publicationId,
        name: chapterTitle ?? "Unknown Chapter",
        url: currentUrl,
        dateUpload: DateTime.now(), // Placeholder (actual date parsing can be added)
      );

      // ✅ Ensure chapter is not null before accessing its properties
      if (formattedText.isNotEmpty && chapter != null) {
        pages.add(ChapterPage(
          id: pages.length + 1, // Unique ID for Hive storage
          chapterId: chapter!.id, // ✅ Now safe since chapter is confirmed non-null
          pageNo: 1, // Only one page for novels
          finished: false, // Default to unread
          url: currentUrl,
          imageUrl: null, // No images for novels
          text: formattedText, // ✅ Store properly formatted text
        ));
      }

      // ✅ Dispose WebView & complete future
      controller.dispose();
      completer.complete(ChapterDetails(chapter: chapter!, pages: pages));
    },
  );

  await headlessWebView.run();
  return completer.future;
}