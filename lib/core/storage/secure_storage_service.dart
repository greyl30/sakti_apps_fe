import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _userKey = 'auth_user';

  // Menyimpan access token ke secure storage
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Menyimpan data user agar homepage dapat memakai data tanpa request ulang
  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
