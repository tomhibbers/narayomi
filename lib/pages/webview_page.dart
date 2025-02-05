import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Needed to open external browser
import 'dart:async';

class WebViewPage extends StatefulWidget {
  final String url;
  final String publicationTitle;

  const WebViewPage({super.key, required this.url, required this.publicationTitle});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with SingleTickerProviderStateMixin {
  InAppWebViewController? webViewController;
  bool canGoBack = false;
  bool canGoForward = false;
  bool isLoading = true;
  String currentUrl = "";

  late ScrollController _scrollController;
  late Timer _scrollTimer;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
    _scrollController = ScrollController();
    _startScrolling();
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() {
    _scrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        double currentPosition = _scrollController.offset;

        if (currentPosition < maxScrollExtent) {
          _scrollController.jumpTo(currentPosition + 1);
        } else {
          _scrollController.jumpTo(0); // Restart scrolling when reaching the end
        }
      }
    });
  }

  void _openInBrowser() async {
    final Uri uri = Uri.parse(currentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open browser")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.publicationTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 18,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 40),
                    child: Text(
                      currentUrl,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: canGoBack ? () async {
              await webViewController?.goBack();
              _updateNavButtons();
            } : null,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: canGoForward ? () async {
              await webViewController?.goForward();
              _updateNavButtons();
            } : null,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "refresh") {
                webViewController?.reload();
              } else if (value == "browser") {
                _openInBrowser();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "refresh",
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text("Refresh Page"),
                ),
              ),
              PopupMenuItem(
                value: "browser",
                child: ListTile(
                  leading: Icon(Icons.open_in_browser),
                  title: Text("Open in Browser"),
                ),
              ),
            ],
            icon: Icon(Icons.more_vert), // ✅ 3-dot vertical menu icon
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) {
              webViewController = controller;
              _updateNavButtons();
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
                currentUrl = url?.toString() ?? widget.url;
                _startScrolling();
              });
              _updateNavButtons();
            },
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _updateNavButtons() async {
    if (webViewController != null) {
      bool canGoBackStatus = await webViewController!.canGoBack();
      bool canGoForwardStatus = await webViewController!.canGoForward();
      setState(() {
        canGoBack = canGoBackStatus;
        canGoForward = canGoForwardStatus;
      });
    }
  }
}
