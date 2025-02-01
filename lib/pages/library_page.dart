import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/services/ranobes_scraper.dart';
import '../models/publication.dart';
import '../services/comick_scraper.dart'; // ✅ Updated import
import '../models/content_type.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Publication> comics = [];
  List<Map<String, String>> searchResults = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  void _loadComics() {
    var box = Hive.box<Publication>('publications');
    setState(() {
      comics = box.values.toList();
    });
  }

  void _searchComics() async {
    String query = _controller.text.trim();
    if (query.isEmpty) return;
    // List<Map<String, String>> results = await scrapeRaNobesInBackgroundSearch(query);
    // // List<Map<String, String>> results = await scrapeComickInBackground(query); // ✅ Updated function
    // setState(() {
    //   searchResults = results;
    // });
  }

  void _saveToLibrary(Map<String, String> comic) async {
    var box = Hive.box<Publication>('publications');

    var newComic = Publication(
      id: comic['url']!.split('/').last,
      title: comic['title']!,
      type: ContentType.Comic,
      typeId: 0,
      url: comic['url']!,
      thumbnailUrl: comic['imageUrl'],
      dateAdded: DateTime.now(),
    );

    await box.put(newComic.id, newComic);
    _loadComics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadComics,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search for comics...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchComics,
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      var comic = searchResults[index];
                      return ListTile(
                        leading: comic['imageUrl'] != null
                            ? Image.network(comic['imageUrl']!, width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.book),
                        title: Text(comic['title']!),
                        subtitle: Text("Tap to add to library"),
                        onTap: () => _saveToLibrary(comic),
                      );
                    },
                  )
                : comics.isEmpty
                    ? Center(child: Text("No comics in library"))
                    : ListView.builder(
                        itemCount: comics.length,
                        itemBuilder: (context, index) {
                          var comic = comics[index];
                          return ListTile(
                            leading: comic.thumbnailUrl != null
                                ? Image.network(comic.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover)
                                : Icon(Icons.book),
                            title: Text(comic.title),
                            subtitle: Text("Stored in library"),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
