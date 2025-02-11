import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/widgets/details/tracking_search_state.dart';
import 'package:narayomi/widgets/details/tracking_tracked_state.dart';

class TrackingBottomDrawer extends StatefulWidget {
  final String publicationId;

  TrackingBottomDrawer({required this.publicationId});

  @override
  _TrackingBottomDrawerState createState() => _TrackingBottomDrawerState();
}

class _TrackingBottomDrawerState extends State<TrackingBottomDrawer> {
  bool _isTracked = false;
  String _listStatus = "Reading";
  int _currentChapter = 1;
  int _score = 0;
  String? _trackedTitle;
  List<Map<String, String>> _searchResults = [];
  String? _selectedResultId;

  Future<void> _searchMangaUpdates() async {
    log("Searching for: mock query...");
    setState(() {
      _searchResults = [
        {"id": "1", "title": "One Piece", "summary": "Pirates and adventures."},
        {"id": "2", "title": "Naruto", "summary": "Ninjas and battles."},
      ];
    });
  }

  void _selectResult(String id) {
    setState(() {
      _selectedResultId = id;
    });
    log("Selected result: $id");
  }

  void _trackSelectedResult() {
    final selectedResult = _searchResults
        .firstWhere((result) => result['id'] == _selectedResultId);
    setState(() {
      _isTracked = true;
      _trackedTitle = selectedResult['title'];
      _searchResults.clear();
      _selectedResultId = null;
    });
    log("Tracking publication: $_trackedTitle");
  }

  void _removeTracking() {
    log("Removed tracking.");
    setState(() {
      _isTracked = false;
      _listStatus = "Reading";
      _currentChapter = 1;
      _score = 0;
      _trackedTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: _isTracked
            ? TrackingTrackedState(
                trackedTitle: _trackedTitle ?? "",
                listStatus: _listStatus,
                currentChapter: _currentChapter,
                score: _score,
                onListStatusChanged: (value) =>
                    setState(() => _listStatus = value),
                onCurrentChapterChanged: (value) =>
                    setState(() => _currentChapter = value),
                onScoreChanged: (value) => setState(() => _score = value),
                onRemoveTracking: _removeTracking,
                onShowOptions: _showOptionsMenu,
              )
            : TrackingSearchState(
                searchResults: _searchResults,
                selectedResultId: _selectedResultId,
                onSelectResult: _selectResult,
                onSearch: _searchMangaUpdates,
                onTrack: _trackSelectedResult,
              ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.open_in_browser),
                title: Text("Open in Browser"),
                onTap: () {
                  Navigator.pop(context);
                  log("Open in Browser tapped.");
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Remove Tracking"),
                onTap: () {
                  Navigator.pop(context);
                  _removeTracking();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
