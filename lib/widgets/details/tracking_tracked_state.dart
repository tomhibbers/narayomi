import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/services/mangaupdates_service.dart';
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
  });

  int _findListIdForStatus(String listStatus) {
    return listMapping.entries
        .firstWhere((entry) => entry.value == listStatus,
            orElse: () => MapEntry(0, "Unknown"))
        .key;
  }

  Future<void> _handleListChange(int newListId) async {
    onListStatusChanged(listMapping[newListId]!);
    try {
      await service.updateTracking(seriesId, newListId);
      log("Successfully updated list to: ${listMapping[newListId]}");
    } catch (error) {
      log("Failed to update list: $error");
    }
  }

  Future<void> _handleChapterChange(int newChapter) async {
    onCurrentChapterChanged(newChapter);
    try {
      await service.updateTracking(seriesId, _findListIdForStatus(listStatus),
          chapter: newChapter);
      log("Successfully updated chapter to: $newChapter");
    } catch (error) {
      log("Failed to update chapter: $error");
    }
  }

  Future<void> _handleScoreChange(int newScore) async {
    onScoreChanged(newScore);
    try {
      await service.updateTracking(seriesId, _findListIdForStatus(listStatus),
          chapter: currentChapter);
      log("Successfully updated score to: $newScore");
    } catch (error) {
      log("Failed to update score: $error");
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
      _handleChapterChange(manualChapter);
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
        Text("Title: $trackedTitle",
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 10),

        // List Dropdown
        TrackingCustomDropdown(
          label: "List",
          currentValue: _findListIdForStatus(listStatus),
          items: listMapping,
          onChanged: (value) => _handleListChange(value),
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
              _handleChapterChange(value);
            }
          },
        ),
        const SizedBox(height: 10),

        // Score Dropdown
        TrackingCustomDropdown(
          label: "Score",
          currentValue: score,
          items: List.generate(11, (i) => i.toString()).asMap(),
          onChanged: (value) => _handleScoreChange(value),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _confirmRemoveTracking(context),
          child: Text("Remove Tracking"),
        ),
      ],
    );
  }
}
