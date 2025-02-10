import 'dart:developer';

import 'package:narayomi/api/mangaupdates_api.dart';

import '../utils/secure_storage.dart';

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
}
