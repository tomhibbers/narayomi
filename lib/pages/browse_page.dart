import 'package:flutter/material.dart';
import 'package:narayomi/widgets/common/publication_card.dart';
import '../models/publication.dart';
import '../services/ranobes_scraper.dart';
import '../services/comick_scraper.dart';
import 'details_page.dart'; // ✅ Import the new Details Page

class BrowsePage extends StatefulWidget {
  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage>
    with SingleTickerProviderStateMixin {
  List<Publication> searchResults = [];
  TextEditingController _controller = TextEditingController();
  bool isLoading = false;
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
      searchResults = [];
    });

    List<Publication> results = [];

    if (_tabController.index == 0) {
      results = await scrapeRaNobesInBackgroundSearch(query); // ✅ Light Novels
    } else {
      results = await scrapeComickInBackground(query); // ✅ Comics
    }

    setState(() {
      isLoading = false;
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Browse"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Light Novels"),
            Tab(text: "Graphic Novels"),
          ],
        ),
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
            child: searchResults.isEmpty
                ? Center(child: Text("No results found"))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return PublicationCard(
                          publication: searchResults[
                              index]); // ✅ Now using PublicationCard
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
