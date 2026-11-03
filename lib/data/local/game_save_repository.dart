import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GameSaveRepository {
  static const _key = 'immortal_cultivation.save';
  final _preferences = SharedPreferencesAsync();

  Future<Map<String, dynamic>?> load() async {
    final data = await _preferences.getString(_key);
    if (data == null) return null;

    final save = jsonDecode(data) as Map<String, dynamic>;
    if (save['version'] != 1) {
      throw const FormatException('Unsupported save version');
    }
    return save;
  }

  Future<void> save(Map<String, Object?> snapshot) =>
      _preferences.setString(_key, jsonEncode(snapshot));
}
