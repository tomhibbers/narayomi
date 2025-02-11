import 'package:flutter/material.dart';
import 'package:narayomi/widgets/details/tracking_custom_dropdown.dart';

class TrackingTrackedState extends StatelessWidget {
  final String trackedTitle;
  final String listStatus;
  final int currentChapter;
  final int score;
  final ValueChanged<String> onListStatusChanged;
  final ValueChanged<int> onCurrentChapterChanged;
  final ValueChanged<int> onScoreChanged;
  final VoidCallback onRemoveTracking;
  final VoidCallback onShowOptions;

  const TrackingTrackedState({
    required this.trackedTitle,
    required this.listStatus,
    required this.currentChapter,
    required this.score,
    required this.onListStatusChanged,
    required this.onCurrentChapterChanged,
    required this.onScoreChanged,
    required this.onRemoveTracking,
    required this.onShowOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Currently Tracking",
                style: Theme.of(context).textTheme.headlineSmall),
            IconButton(icon: Icon(Icons.more_vert), onPressed: onShowOptions),
          ],
        ),
        const SizedBox(height: 10),
        Text("Title: $trackedTitle",
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 10),
        TrackingCustomDropdown(
            label: "List",
            currentValue: listStatus,
            items: ["Reading", "Completed", "On-Hold", "Dropped"],
            onChanged: onListStatusChanged),
        const SizedBox(height: 10),
        TrackingCustomDropdown(
            label: "Current Chapter",
            currentValue: currentChapter.toString(),
            items: List.generate(500, (i) => (i + 1).toString()),
            onChanged: (value) => onCurrentChapterChanged(int.parse(value))),
        const SizedBox(height: 10),
        TrackingCustomDropdown(
            label: "Score",
            currentValue: score.toString(),
            items: List.generate(11, (i) => i.toString()),
            onChanged: (value) => onScoreChanged(int.parse(value))),
      ],
    );
  }
}
