import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/content_type.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/widgets/common/publication_card.dart';
import 'package:narayomi/widgets/common/publication_list.dart';
import 'dart:developer';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  bool isGridView = true; // ✅ Default to Grid View
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
        actions: [
          /// ✅ Toggle Button (Switch List/Grid View)
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isGridView ? buildGridView(novels) : buildListView(novels),
          isGridView ? buildGridView(comics) : buildListView(comics),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
