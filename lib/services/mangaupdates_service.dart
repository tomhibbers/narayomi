import 'dart:developer';
import 'package:narayomi/api/mangaupdates_api.dart';
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
}
