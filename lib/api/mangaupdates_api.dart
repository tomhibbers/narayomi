import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:narayomi/models/api/mangaupdates_list_series.dart';
import 'package:narayomi/models/api/mangaupdates_series.dart';
import 'dart:convert';
import 'package:narayomi/utils/secure_storage.dart';

class MangaUpdatesApi {
  static const String baseUrl = "https://api.mangaupdates.com/v1";

  /// Authenticates the user with MangaUpdates and returns a session token.
  Future<String?> authenticate(String username, String password) async {
    final url = Uri.parse("$baseUrl/account/login");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sessionToken = data['context']?['session_token'];

      if (sessionToken != null) {
        return sessionToken;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<MangaUpdatesSeries>> searchSeries(String query,
      {int page = 1, int perPage = 10}) async {
    final token = await SecureStorage.getSessionToken();
    final url = Uri.parse('$baseUrl/series/search');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'search': query,
        'page': page,
        'per_page': perPage,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => MangaUpdatesSeries.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search series: ${response.body}');
    }
  }

  Future<bool> addSeriesToList(int seriesId, int listId,
      {int chapter = 0}) async {
    final token = await SecureStorage.getSessionToken();
    final url = Uri.parse('$baseUrl/lists/series');

    final requestBody = [
      {
        "series": {"id": seriesId},
        "list_id": listId,
        "status": {"chapter": chapter},
      }
    ];

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      log('Successfully added series $seriesId to list $listId.');
      return true;
    } else {
      log('Failed to add series to list: ${response.body}');
      return false;
    }
  }

  Future<MangaUpdatesListSeries?> fetchSeriesTrackingDetails(
      int seriesId) async {
    final token = await SecureStorage.getSessionToken();
    final url = Uri.parse('$baseUrl/lists/series/$seriesId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Fetched list details for series $seriesId.');
      return MangaUpdatesListSeries.fromJson(data);
    } else if (response.statusCode == 404) {
      log('Series $seriesId is not on any list.');
      return null;
    } else {
      log('Failed to fetch list details: ${response.body}');
      return null;
    }
  }

  Future<bool> updateSeriesTracking(int seriesId, int listId,
      {int chapter = 0}) async {
    final token = await SecureStorage.getSessionToken();
    final url = Uri.parse('$baseUrl/lists/series/update');

    final requestBody = [
      {
        "series": {"id": seriesId},
        "list_id": listId,
        "status": {"chapter": chapter}
      }
    ];

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      log('Successfully updated series $seriesId on list $listId.');
      return true;
    } else {
      log('Failed to update series tracking: ${response.body}');
      return false;
    }
  }

  Future<bool> removeSeriesFromTracking(int seriesId) async {
    final token = await SecureStorage.getSessionToken();
    final url = Uri.parse('$baseUrl/lists/series/delete');

    final requestBody = [seriesId]; // Payload is an array with the series ID

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      log('Successfully removed series $seriesId from tracking.');
      return true;
    } else {
      log('Failed to remove series from tracking: ${response.body}');
      return false;
    }
  }

  Future<Map<int, String>> fetchTrackingLists() async {
    final token = await SecureStorage.getSessionToken();
    final url = Uri.parse('$baseUrl/lists');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      log('Fetched tracking lists.');

      return {
        for (var list in data)
          list['list_id']: list['title'] // Mapping list_id to title
      };
    } else {
      log('Failed to fetch tracking lists: ${response.body}');
      return {};
    }
  }
}
