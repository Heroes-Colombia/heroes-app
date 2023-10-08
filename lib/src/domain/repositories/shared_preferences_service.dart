import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> getBool(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(key) ?? false;
  }

  Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(key, value);
  }

  Future<String> getString(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key) ?? '';
  }

  Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(key, value);
  }

  Future<int> getInt(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt(key) ?? 0;
  }

  Future<bool> setInt(String key, int value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(key, value);
  }

  Future<double> getDouble(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getDouble(key) ?? 0.0;
  }

  Future<bool> setDouble(String key, double value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setDouble(key, value);
  }

  Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }

  Future<bool> containsKey(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(key);
  }

  Future<Set<String>> getKeys() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getKeys();
  }
}
