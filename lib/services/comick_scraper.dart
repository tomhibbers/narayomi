import 'dart:async';
import 'dart:developer';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import '../models/publication.dart';
import '../models/content_type.dart';

String lastHtmlResponse = ""; // ✅ Store for debugging

Future<List<Publication>> scrapeComickInBackground(String query) async {
  Completer<List<Publication>> completer = Completer();
  List<Publication> results = [];

  // var headlessWebView = HeadlessInAppWebView(
  //   initialUrlRequest:
  //       URLRequest(url: WebUri("https://comick.io/search?q=$query")),
  //   onLoadStop: (controller, url) async {
  //     print("onLoadStop");
  //     lastHtmlResponse = await controller.evaluateJavascript(
  //         source: "document.documentElement.outerHTML");

  //     String js = '''
  //       (() => {
  //         return [...document.querySelectorAll('.pl-3')].map(item => ({
  //           title: item.querySelector('.font-bold truncate')?.textContent.trim(),
  //           url: item.querySelector('a')?.href,
  //           imageUrl: item.querySelector('img.select-none')?.getAttribute('srcset')?.split(',').pop().trim().split(' ')[0] || item.querySelector('img.select-none')?.src
  //         }));
  //       })();
  //     ''';

  //     var scrapedResults = await controller.evaluateJavascript(source: js);

  //     if (scrapedResults != null) {
  //       print('TESTSETSETS');
  //       results = List<Map<String, String>>.from(scrapedResults);
  //     }
  //   },
  // );

  // await headlessWebView.run(); // ✅ Start headless WebView
  // await headlessWebView
  //     .dispose(); // ✅ Now dispose properly after `run()` finishes
  return results;
}
