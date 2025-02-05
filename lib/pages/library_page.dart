import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/content_type.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/widgets/common/publication_card.dart';
import 'dart:developer';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Publication> novels = [];
  List<Publication> comics = [];

  @override
  void initState() {
    _tabController =
        TabController(length: 2, vsync: this); // ✅ Initialize FIRST
    super.initState(); // ✅ Then call super.initState()
    _loadLibrary(); // ✅ Load data after initialization
  }

  void _loadLibrary() async {
    var box = await Hive.openBox<Publication>('library_v3');

    List<Publication> allPublications = box.values.toList();

    setState(() {
      novels = allPublications
          .where((p) => p.type == ContentType.Novel)
          .toList(); // Light Novels
      comics = allPublications
          .where((p) => p.type == ContentType.Comic)
          .toList(); // Graphic Novels
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Novels"),
            Tab(text: "Comics"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLibraryList(novels),
          _buildLibraryList(comics),
        ],
      ),
    );
  }

  Widget _buildLibraryList(List<Publication> publications) {
    if (publications.isEmpty) {
      return Center(
          child: Text("No items in your library."));
    }

    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: publications.length,
      itemBuilder: (context, index) {
        return PublicationCard(publication: publications[index]);
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
