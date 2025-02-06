import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Import Riverpod
import 'package:narayomi/models/content_type.dart';
import 'package:narayomi/providers/publication_provider.dart';
import 'package:narayomi/widgets/common/publication_list.dart';

class LibraryPage extends ConsumerStatefulWidget {
  // ✅ Change this
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> // ✅ Change this
    with
        SingleTickerProviderStateMixin {
  bool isGridView = true; // ✅ Default to Grid View
  late TabController _tabController;

  @override
  void initState() {
    _tabController =
        TabController(length: 2, vsync: this); // ✅ Initialize FIRST
    super.initState(); // ✅ Then call super.initState()
  }

  @override
  Widget build(BuildContext context) {
    final publications = ref.watch(publicationProvider); // ✅ Use ref now

    // ✅ Filter novels & comics dynamically
    final novels =
        publications.where((p) => p.type == ContentType.Novel).toList();
    final comics =
        publications.where((p) => p.type == ContentType.Comic).toList();

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
