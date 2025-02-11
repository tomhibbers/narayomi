import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(
      String username, String password, String token) async {
    await _storage.write(key: "mu_username", value: username);
    await _storage.write(key: "mu_password", value: password);
    await _storage.write(key: "mu_token", value: token);
  }

  static Future<Map<String, String?>> getCredentials() async {
    String? username = await _storage.read(key: "mu_username");
    String? password = await _storage.read(key: "mu_password");
    String? token = await _storage.read(key: "mu_token");
    return {"username": username, "password": password, "token": token};
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }

  static Future<String?> getSessionToken() async {
    return await _storage.read(key: "mu_token");
  }
}
