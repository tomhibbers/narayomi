import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

class MangaUpdatesApi {
  static const String _baseUrl = "https://api.mangaupdates.com/v1";

  /// Authenticates the user with MangaUpdates and returns a session token.
  Future<String?> authenticate(String username, String password) async {
    final url = Uri.parse("$_baseUrl/account/login");

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
}
