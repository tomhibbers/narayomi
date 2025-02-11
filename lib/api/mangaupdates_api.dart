import 'package:http/http.dart' as http;
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
}
