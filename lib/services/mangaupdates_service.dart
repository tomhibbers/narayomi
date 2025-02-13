import 'dart:developer';
import 'package:narayomi/api/mangaupdates_api.dart';
import 'package:narayomi/models/api/mangaupdates_list_series.dart';
import 'package:narayomi/models/api/mangaupdates_series.dart';
import 'package:narayomi/models/content_type.dart';
import 'package:narayomi/utils/secure_storage.dart';

class MangaUpdatesService {
  final MangaUpdatesApi _api = MangaUpdatesApi();

  /// Logs in the user using their credentials and stores the session token.
  Future<bool> login(String username, String password) async {
    try {
      String? token = await _api.authenticate(username, password);
      if (token != null) {
        await SecureStorage.saveCredentials(username, password, token);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Clears stored credentials (used for logout functionality).
  Future<void> logout() async {
    await SecureStorage.clearCredentials();
  }

  Future<List<MangaUpdatesSeries>> searchPublication(String query,
      {int page = 1, int perPage = 10, required ContentType type}) async {
    try {
      List<MangaUpdatesSeries> results =
          await _api.searchSeries(query, page: page, perPage: perPage);

      // Filter the results based on the ContentType
      return results.where((series) {
        if (type == ContentType.Novel) {
          return series.status.toLowerCase() == 'novel'; // Keep only novels
        } else {
          return series.status.toLowerCase() !=
              'novel'; // Treat everything else as comic
        }
      }).toList();
    } catch (error) {
      log('Error searching publication: $error');
      return []; // Return an empty list on failure
    }
  }

  Future<bool> addToTracking(int seriesId, int listId) async {
    try {
      final success = await _api.addSeriesToList(seriesId, listId);
      log("Series $seriesId added to list with ID $listId.");
      return success;
    } catch (error) {
      log("Error adding series to tracking: $error");
      return false;
    }
  }

  Future<MangaUpdatesListSeries?> getTrackingDetails(int seriesId) async {
    try {
      final trackingInfo = await _api.fetchSeriesTrackingDetails(seriesId);
      if (trackingInfo != null) {
        final listMapping = await getCachedTrackingLists();
        final listTitle = listMapping[trackingInfo.listId] ?? 'Unknown List';
        log("Series $seriesId is on the list: $listTitle");
        trackingInfo.listType = listTitle; // Update the listType with the title
      }
      return trackingInfo;
    } catch (error) {
      log("Error fetching tracking details: $error");
      return null;
    }
  }

  Future<bool> updateTracking(int seriesId, int listId,
      {int chapter = 0}) async {
    try {
      final success =
          await _api.updateSeriesTracking(seriesId, listId, chapter: chapter);
      if (success) {
        log("Successfully updated tracking for series $seriesId.");
      } else {
        log("Failed to update tracking for series $seriesId.");
      }
      return success;
    } catch (error) {
      log("Error updating tracking for series $seriesId: $error");
      return false;
    }
  }

  Future<bool> removeFromTracking(int seriesId) async {
    try {
      final success = await _api.removeSeriesFromTracking(seriesId);
      if (success) {
        log("Removed series $seriesId from tracking.");
      } else {
        log("Failed to remove series $seriesId from tracking.");
      }
      return success;
    } catch (error) {
      log("Error removing series $seriesId from tracking: $error");
      return false;
    }
  }

  Future<MangaUpdatesListSeries?> checkAndTrackSeries(int seriesId, int listId,
      {int chapter = 0}) async {
    MangaUpdatesListSeries? trackingInfo = await getTrackingDetails(seriesId);

    if (trackingInfo == null) {
      log("Series $seriesId is not on any list. Adding it.");
      final success = await addToTracking(seriesId, listId);
      if (success) {
        trackingInfo = await getTrackingDetails(seriesId);
      }
    } else {
      log("Series $seriesId is already on a list. Updating its tracking info.");
      await updateTracking(seriesId, listId, chapter: chapter);
    }

    return trackingInfo;
  }

  Future<Map<int, String>> getTrackingLists() async {
    try {
      final listMapping = await _api.fetchTrackingLists();
      log("Fetched tracking lists.");
      return listMapping;
    } catch (error) {
      log("Error fetching tracking lists: $error");
      return {};
    }
  }

  Map<int, String>? _cachedTrackingLists;

  Future<Map<int, String>> getCachedTrackingLists() async {
    if (_cachedTrackingLists != null) {
      return _cachedTrackingLists!;
    }

    _cachedTrackingLists = await getTrackingLists();
    return _cachedTrackingLists!;
  }
}
