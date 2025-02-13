import 'package:hive/hive.dart';
import 'package:narayomi/models/tracked_series.dart';

class TrackedSeriesDatabase {
  static Future<Box<TrackedSeries>> _openBox() async {
    return await Hive.openBox<TrackedSeries>('tracked_series');
  }

  static Future<void> addOrUpdateTrackedSeries(TrackedSeries series) async {
    final box = await _openBox();
    await box.put(series.publicationId, series); // Use publicationId as the key
  }

  static Future<TrackedSeries?> getTrackedSeries(String publicationId) async {
    final box = await _openBox();
    return box.get(publicationId);
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
