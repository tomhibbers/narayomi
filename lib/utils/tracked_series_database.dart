import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:narayomi/models/tracked_series.dart';

class TrackedSeriesDatabase {
  static Future<Box<TrackedSeries>> _openBox() async {
    return await Hive.openBox<TrackedSeries>('tracked_series');
  }

  static Future<void> addOrUpdateTrackedSeries(TrackedSeries series) async {
    final box = await Hive.openBox<TrackedSeries>('tracked_series');
    await box.put(series.publicationId, series);
    await box.flush();
  }

  static Future<TrackedSeries?> getTrackedSeries(String publicationId) async {
    final box = await Hive.openBox<TrackedSeries>('tracked_series');
    try {
      for (var key in box.keys) {
        final trackedSeries = box.get(key);
        if (trackedSeries?.publicationId == publicationId) {
          return trackedSeries;
        }
      }
    } catch (error) {
      log("❌ Error while searching tracked series: $error");
    }

    return null;
  }

  static Future<List<TrackedSeries>> getAllTrackedSeries() async {
    final box = await _openBox();
    return box.values.toList();
  }

  static Future<void> deleteTrackedSeries(String publicationId) async {
    final box = await _openBox();
    await box.delete(publicationId);
  }
}
