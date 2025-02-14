import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/services/comick_service.dart';
import 'package:narayomi/services/ranobes_service.dart';
import 'package:narayomi/widgets/common/publication_list.dart'; // ✅ Import helper file

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
      List<Publication> results = await raNobesSearch(query);
      setState(() {
        lightNovelResults = results;
      });
    } else {
      // ✅ Graphic Novels Search
      List<Publication> results = await comickSearch(query);
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
            Tab(text: "Novels", icon: Icon(Icons.library_books_outlined)),
            Tab(text: "Comics", icon: Icon(Icons.collections_outlined)),
          ],
          labelColor: Theme.of(context).colorScheme.secondary,
          indicatorColor: Theme.of(context).colorScheme.secondary,
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
          SizedBox(height: 20), // 🔼 Adjusted to match spacing below
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
              onSubmitted: (value) => _search(),
            ),
          ),
          SizedBox(height: 20), // 🔼 Now equal to the space above
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20), // ✅ Consistent spacing
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildView(lightNovelResults),
                      _buildView(graphicNovelResults),
                    ],
                  ),
                ),
                if (isLoading) Center(child: CircularProgressIndicator()),
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
