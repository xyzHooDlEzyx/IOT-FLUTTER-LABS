import 'dart:convert';

import 'package:my_project/data/repositories/auth_repository.dart';
import 'package:my_project/data/storage/key_value_storage.dart';
import 'package:my_project/domain/models/local_user.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._storage);

  static const String _userKey = 'local_user';
  static const String _loggedInKey = 'logged_in';

  final KeyValueStorage _storage;

  @override
  Future<void> saveUser(LocalUser user) async {
    await _storage.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<LocalUser?> getUser() async {
    final data = await _storage.getString(_userKey);
    if (data == null || data.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return LocalUser.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  @override
  Future<void> setLoggedIn(bool value) async {
    await _storage.setBool(_loggedInKey, value);
  }

  @override
  Future<bool> isLoggedIn() async {
    final loggedIn = await _storage.getBool(_loggedInKey) ?? false;
    if (!loggedIn) {
      return false;
    }

    final user = await getUser();
    return user != null;
  }

  @override
  Future<bool> validateLogin(String email, String password) async {
    final user = await getUser();
    if (user == null) {
      return false;
    }

    return user.email.toLowerCase() == email.toLowerCase() &&
        user.password == password;
  }

  @override
  Future<void> clearUser() async {
    await _storage.remove(_userKey);
    await _storage.setBool(_loggedInKey, false);
  }
}
