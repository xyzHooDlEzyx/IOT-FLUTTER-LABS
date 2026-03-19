import 'package:flutter/material.dart';
import 'package:my_project/data/storage/key_value_storage.dart';
import 'package:my_project/data/storage/shared_prefs_storage.dart';

class ThemeStore extends ChangeNotifier {
  ThemeStore(this._storage);

  static final ThemeStore instance = ThemeStore(SharedPrefsStorage());

  static const String _themeModeKey = 'theme_mode';

  final KeyValueStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final stored = await _storage.getString(_themeModeKey);
    _themeMode = _parseThemeMode(stored) ?? ThemeMode.system;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setString(_themeModeKey, _serializeThemeMode(mode));
    notifyListeners();
  }

  Future<ThemeMode> cycleThemeMode() async {
    final next = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
    return next;
  }

  ThemeMode? _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  String _serializeThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
