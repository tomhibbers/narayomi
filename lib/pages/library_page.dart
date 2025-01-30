import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/publication.dart';
import '../models/content_type.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Publication> comics = [];

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

  Future<void> addTestComic() async {
    var box = Hive.box<Publication>('publications');

    var testComic = Publication(
      id: 'one_piece',
      title: 'One Piece',
      type: ContentType.Comic,
      typeId: 0,
      url: 'https://onepiece.com',
      genres: ['Action', 'Adventure'],
      thumbnailUrl: 'https://meo.comick.pictures/GXmp2p-s.jpg',
      dateAdded: DateTime.now(),
    );

    await box.put(testComic.id, testComic); // ✅ Saves to Hive
    print("Comic added: ${testComic.title}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library")),
      body: comics.isEmpty
          ? Center(child: Text("No comics added yet."))
          : ListView.builder(
              itemCount: comics.length,
              itemBuilder: (context, index) {
                var comic = comics[index];
                return ListTile(
                  leading: comic.thumbnailUrl != null
                      ? Image.network(comic.thumbnailUrl!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.book),
                  title: Text(comic.title),
                  subtitle: Text(comic.genres?.join(', ') ?? "No genres"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addTestComic();
          _loadComics(); // Reload UI after adding
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
