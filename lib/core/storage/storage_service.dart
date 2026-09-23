abstract class StorageService {
  Future<void> init();
  
  String? getString(String key);
  Future<bool> setString(String key, String value);

  int? getInt(String key);
  Future<bool> setInt(String key, int value);

  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  double? getDouble(String key);
  Future<bool> setDouble(String key, double value);

  List<String>? getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);

  bool containsKey(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
}
