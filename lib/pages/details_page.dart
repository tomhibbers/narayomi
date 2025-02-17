import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/models/tracked_series.dart';
import 'package:narayomi/providers/publication_details_provider.dart';
import 'package:narayomi/providers/publication_provider.dart';
import 'package:narayomi/services/mangaupdates_service.dart';
import 'package:narayomi/utils/tracked_series_database.dart';
import 'package:narayomi/widgets/details/details_header.dart';
import 'package:narayomi/widgets/details/genres_component.dart';
import 'package:narayomi/widgets/details/expandable_description.dart';
import 'package:narayomi/widgets/details/action_buttons.dart';
import 'package:narayomi/widgets/details/chapters_component.dart';

class DetailsPage extends ConsumerStatefulWidget {
  final Publication publication;

  const DetailsPage({super.key, required this.publication});

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  bool _isTracked = false;
  TrackedSeries? _trackedSeries;

  @override
  void initState() {
    super.initState();
    _fetchTrackingStatus();
    _syncTrackingInfo();

    Future.microtask(() async {
      final pubBox = await Hive.openBox<Publication>('library_v3');
      final normalizedId = widget.publication.id.trim().toLowerCase();

      if (!pubBox.containsKey(normalizedId)) {
        // ✅ If not in library, fetch full details
        ref
            .read(publicationDetailsProvider.notifier)
            .refreshPublication(widget.publication);
      } else {
        // ✅ Load from cache if available
        ref
            .read(publicationDetailsProvider.notifier)
            .loadPublicationDetails(widget.publication);
      }
    });
  }

  void refreshLibrary() {
    ref.invalidate(publicationProvider); // ✅ Force the library list to refresh
  }

  Future<void> _fetchTrackingStatus() async {
    final trackedSeries =
        await TrackedSeriesDatabase.getTrackedSeries(widget.publication.id);
    if (trackedSeries != null) {
      setState(() {
        _isTracked = true;
        _trackedSeries = trackedSeries;
      });
      log("Tracking found for publication ${widget.publication.id}");
    } else {
      _isTracked = false;
      _trackedSeries = null;
      log("No tracking found for publication ${widget.publication.id}");
    }
  }

  Future<void> _syncTrackingInfo() async {
    if (_trackedSeries == null) {
      log("No tracked series available. Skipping sync.");
      return;
    }

    log("Syncing tracking info for seriesId ${_trackedSeries!.id}");
    final latestTrackingInfo =
        await MangaUpdatesService().getTrackingDetails(_trackedSeries!.id);

    if (latestTrackingInfo != null) {
      final updatedSeries = TrackedSeries(
        id: latestTrackingInfo.seriesId,
        publicationId: widget.publication.id,
        listId: latestTrackingInfo.listId,
        currentChapter: latestTrackingInfo.chapter,
        score: latestTrackingInfo.priority ?? 0,
        title: latestTrackingInfo.title,
      );

      await TrackedSeriesDatabase.addOrUpdateTrackedSeries(updatedSeries);
      setState(() {
        _trackedSeries = updatedSeries;
        _isTracked = true;
      });

      log("Tracking info synced successfully for ${updatedSeries.publicationId}");
    } else {
      log("No updated tracking info found.");
    }
  }

  void trackingChanged() async {
    log("🚀 Tracking status changed. Refreshing UI...");

    await _fetchTrackingStatus(); // ✅ Reload tracking status

    setState(() {
      log("✅ State updated in DetailsPage!");
    });
  }

  @override
  Widget build(BuildContext context) {
    final details =
        ref.watch(publicationDetailsProvider)[widget.publication.id];

    return Scaffold(
      body: details == null || details.isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // ✅ Show loading indicator while fetching
          : CustomScrollView(
              slivers: [
                DetailsHeader(
                  publication: details.publication,
                  scrollOffset: 0,
                  onRefresh: () => ref
                      .read(publicationDetailsProvider.notifier)
                      .refreshPublication(details.publication),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        ActionButtons(
                          publication: details.publication,
                          onLibraryChange: refreshLibrary,
                          isTracked: _isTracked,
                          trackedSeries: _trackedSeries,
                          onTrackingChange: trackingChanged,
                        ),
                        SizedBox(height: 16),
                        ExpandableDescription(
                          description: details.publication.description ??
                              "No description available.",
                        ),
                        SizedBox(height: 16),
                        GenresComponent(
                            genres: details.publication.genres ?? []),
                        SizedBox(height: 16),
                        ChaptersComponent(
                            chapters: details.chapters,
                            publication: details.publication),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
