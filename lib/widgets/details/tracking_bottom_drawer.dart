import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/widgets/details/tracking_search_state.dart';
import 'package:narayomi/widgets/details/tracking_tracked_state.dart';
import 'package:narayomi/services/mangaupdates_service.dart';
import 'package:narayomi/models/api/mangaupdates_series.dart';

class TrackingBottomDrawer extends StatefulWidget {
  final Publication publicationId;

  TrackingBottomDrawer({required this.publicationId});

  @override
  _TrackingBottomDrawerState createState() => _TrackingBottomDrawerState();
}

class _TrackingBottomDrawerState extends State<TrackingBottomDrawer> {
  final MangaUpdatesService _service = MangaUpdatesService();
  bool _isTracked = false;
  int? _trackedSeriesId;
  String _listStatus = "Reading";
  int _currentChapter = 1;
  int _score = 0;
  String? _trackedTitle;
  List<Map<String, String>> _searchResults = [];
  String? _selectedResultId;
  String _searchQuery = "";
  Map<int, String> _listMapping = {};

  @override
  void initState() {
    super.initState();
    _fetchListMapping();
  }

  Future<void> _fetchListMapping() async {
    final listMapping = await _service.getCachedTrackingLists();
    setState(() {
      _listMapping = listMapping;
    });
  }

  Future<void> _searchMangaUpdates(String query) async {
    if (query.isEmpty) {
      log("Query is empty, skipping search.");
      return;
    }

    log("Searching for: $query");

    try {
      List<MangaUpdatesSeries> results = await _service.searchPublication(query,
          type: widget.publicationId.type);

      setState(() {
        _searchResults = results.map((series) {
          return {
            "id": series.seriesId,
            "title": series.title,
            "summary": series.description.isNotEmpty
                ? series.description
                : "No description available",
            "imageUrl": series.imageUrl,
          };
        }).toList();
      });

      log("Found ${results.length} results.");
    } catch (error) {
      log("Error during search: $error");
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _selectResult(String id) {
    setState(() {
      _selectedResultId = id;
    });
    log("Selected result: $id");
  }

  int _findListIdForStatus(String listStatus) {
    return _listMapping.entries
        .firstWhere((entry) => entry.value == listStatus,
            orElse: () => MapEntry(0, "Unknown"))
        .key;
  }

  void _trackSelectedResult() async {
    final selectedResult = _searchResults
        .firstWhere((result) => result['id'] == _selectedResultId);
    final int seriesId =
        int.parse(selectedResult['id']!); // Extract the seriesId

    try {
      final trackingInfo = await _service.checkAndTrackSeries(
          seriesId, _findListIdForStatus("Reading List"));

      if (trackingInfo != null) {
        setState(() {
          _isTracked = true;
          _trackedSeriesId = seriesId; // Store the tracked series ID
          _trackedTitle = trackingInfo.title;
          _listStatus = trackingInfo.listType ?? "Unknown";
          _currentChapter = trackingInfo.chapter;
          _score = trackingInfo.priority ?? 0;
          _searchResults.clear();
          _selectedResultId = null;
        });
        log("Successfully tracked series: ${trackingInfo.title}");
      } else {
        log("Failed to track series.");
      }
    } catch (error) {
      log("Error tracking series: $error");
    }
  }

  void _removeTracking() async {
    if (_trackedSeriesId == null) {
      log("No tracked series to remove.");
      return;
    }

    try {
      final success = await _service.removeFromTracking(_trackedSeriesId!);
      if (success) {
        log("Removed tracking for series $_trackedSeriesId.");
        setState(() {
          _isTracked = false;
          _trackedSeriesId = null;
          _listStatus = "Reading";
          _currentChapter = 0;
          _score = 0;
          _trackedTitle = null;
        });
      } else {
        log("Failed to remove tracking for series $_trackedSeriesId.");
      }
    } catch (error) {
      log("Error removing tracking: $error");
    }
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
                listMapping: _listMapping,
                service: _service,
                seriesId: _trackedSeriesId ?? 0,
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
