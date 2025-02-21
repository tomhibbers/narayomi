import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/models/tracked_series.dart';
import 'package:narayomi/services/mangaupdates_service.dart';
import 'package:narayomi/utils/tracked_series_database.dart';
import 'package:narayomi/widgets/common/toast_utils.dart';
import 'package:narayomi/widgets/details/tracking_custom_dropdown.dart';

class TrackingTrackedState extends StatelessWidget {
  final String trackedTitle;
  final String listStatus;
  final int currentChapter;
  final int score;
  final int seriesId; // New prop
  final MangaUpdatesService service; // New prop
  final ValueChanged<String> onListStatusChanged;
  final ValueChanged<int> onCurrentChapterChanged;
  final ValueChanged<int> onScoreChanged;
  final VoidCallback onRemoveTracking;
  final VoidCallback onShowOptions;
  final Map<int, String> listMapping;
  final String publicationId;
  const TrackingTrackedState({
    required this.trackedTitle,
    required this.listStatus,
    required this.currentChapter,
    required this.score,
    required this.seriesId,
    required this.service,
    required this.onListStatusChanged,
    required this.onCurrentChapterChanged,
    required this.onScoreChanged,
    required this.onRemoveTracking,
    required this.onShowOptions,
    required this.listMapping,
    required this.publicationId,
  });

  int _findListIdForStatus(String listStatus) {
    return listMapping.entries
        .firstWhere((entry) => entry.value == listStatus,
            orElse: () => MapEntry(0, "Unknown"))
        .key;
  }

  Future<void> _handleListChange(BuildContext context, int newListId) async {
    onListStatusChanged(listMapping[newListId]!);
    try {
      await service.updateTracking(seriesId, newListId);
      await TrackedSeriesDatabase.addOrUpdateTrackedSeries(TrackedSeries(
        id: seriesId,
        publicationId: publicationId,
        listId: newListId,
        currentChapter: currentChapter,
        score: score,
        title: trackedTitle,
      ));
      ToastUtils.showToast(
          context, "List status updated to ${listMapping[newListId]}");
    } catch (error) {
      ToastUtils.showToast(context, "Failed to update list status");
    }
  }

  Future<void> _handleChapterChange(
      BuildContext context, int newChapter) async {
    onCurrentChapterChanged(newChapter);
    try {
      await service.updateTracking(seriesId, _findListIdForStatus(listStatus),
          chapter: newChapter);
      await TrackedSeriesDatabase.addOrUpdateTrackedSeries(TrackedSeries(
        id: seriesId,
        publicationId: publicationId,
        listId: _findListIdForStatus(listStatus),
        currentChapter: newChapter,
        score: score,
        title: trackedTitle,
      ));
      ToastUtils.showToast(context, "Chapter updated to $newChapter");
    } catch (error) {
      ToastUtils.showToast(context, "Failed to update chapter");
    }
  }

  Future<void> _handleScoreChange(BuildContext context, int newScore) async {
    onScoreChanged(newScore);
    try {
      await service.updateTracking(seriesId, _findListIdForStatus(listStatus),
          chapter: currentChapter);
      await TrackedSeriesDatabase.addOrUpdateTrackedSeries(TrackedSeries(
        id: seriesId,
        publicationId: publicationId,
        listId: _findListIdForStatus(listStatus),
        currentChapter: currentChapter,
        score: newScore,
        title: trackedTitle,
      ));
      ToastUtils.showToast(context, "Score updated to $newScore");
    } catch (error) {
      ToastUtils.showToast(context, "Failed to update score");
    }
  }

  Future<void> _showManualChapterInputDialog(BuildContext context) async {
    int? manualChapter = await showDialog<int>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text("Enter Chapter Number"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Chapter number"),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, int.tryParse(controller.text)),
              child: Text("OK"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );

    if (manualChapter != null && manualChapter > 0) {
      _handleChapterChange(context, manualChapter);
    }
  }

  List<int> generateChapterList(int currentChapter) {
    int start =
        currentChapter > 200 ? currentChapter - 200 : 0; // Lower bound is 0
    int end = currentChapter + 200;
    return List.generate(end - start + 1, (i) => start + i);
  }

  Future<void> _confirmRemoveTracking(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove Tracking"),
          content: Text("Are you sure you want to stop tracking this series?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Remove"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      onRemoveTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapterList = generateChapterList(currentChapter);
    final Map<int, String> chapterMap = {
      for (int chapter in chapterList) chapter: chapter.toString(),
      -1: "Other", // Manual Input Option
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Title: $trackedTitle",
                style: Theme.of(context).textTheme.bodyLarge),
            ElevatedButton(
              onPressed: () => _confirmRemoveTracking(context),
              child: Text("Remove Tracking",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // List Dropdown
        TrackingCustomDropdown(
          label: "List",
          currentValue: _findListIdForStatus(listStatus),
          items: listMapping,
          onChanged: (value) => _handleListChange(context, value),
        ),
        const SizedBox(height: 10),

        // Chapter Dropdown
        TrackingCustomDropdown(
          label: "Current Chapter",
          currentValue:
              chapterMap.containsKey(currentChapter) ? currentChapter : -1,
          items: chapterMap,
          onChanged: (value) {
            if (value == -1) {
              _showManualChapterInputDialog(context);
            } else {
              _handleChapterChange(context, value);
            }
          },
        ),
        const SizedBox(height: 10),

        // Score Dropdown
        TrackingCustomDropdown(
          label: "Score",
          currentValue: score,
          items: List.generate(11, (i) => i.toString()).asMap(),
          onChanged: (value) => _handleScoreChange(context, value),
        ),
      ],
    );
  }
}
