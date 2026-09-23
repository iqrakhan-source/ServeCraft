import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class SharedPrefsStorageService implements StorageService {
  SharedPreferences? _preferences;

  SharedPrefsStorageService([SharedPreferences? preferences])
      : _preferences = preferences;

  @override
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefs {
    if (_preferences == null) {
      throw StateError(
          'SharedPrefsStorageService has not been initialized. Call init() before accessing storage.');
    }
    return _preferences!;
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);

  @override
  Future<bool> clear() => _prefs.clear();
}
