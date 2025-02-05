import 'package:flutter/material.dart';
import 'package:narayomi/widgets/common/publication_list.dart'; // ✅ Import helper file
import '../models/publication.dart';
import '../services/ranobes_scraper.dart';
import '../services/comick_scraper.dart';

class BrowsePage extends StatefulWidget {
  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage>
    with SingleTickerProviderStateMixin {
  List<Publication> lightNovelResults =
      []; // ✅ Separate results for Light Novels
  List<Publication> graphicNovelResults =
      []; // ✅ Separate results for Graphic Novels
  TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  bool isGridView = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _search() async {
    String query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    if (_tabController.index == 0) {
      // ✅ Light Novels Search
      List<Publication> results = await scrapeRaNobesSearch(query);
      setState(() {
        lightNovelResults = results;
      });
    } else {
      // ✅ Graphic Novels Search
      List<Publication> results = await scrapeComickSearch(query);
      setState(() {
        graphicNovelResults = results;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Browse"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Light Novels"),
            Tab(text: "Graphic Novels"),
          ],
        ),
        actions: [
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (value) => _search(),
            ),
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildView(lightNovelResults), // ✅ Shows Light Novel results
                _buildView(
                    graphicNovelResults), // ✅ Shows Graphic Novel results
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Unified method to switch between List and Grid views
  Widget _buildView(List<Publication> publications) {
    if (isGridView) {
      return buildGridView(publications);
    } else {
      return buildListView(publications);
    }
  }
}
