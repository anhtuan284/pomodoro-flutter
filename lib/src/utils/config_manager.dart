import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// [ConfigManager] is a singleton design for manage
/// App Configuration in Local Storage (Web), Shared_pref (Android)
class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();

  factory ConfigManager() {
    return _instance;
  }

  ConfigManager._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> loadConfigurations() async {
    await _initPrefs();
    String? configJson = _prefs?.getString('appConfig');
    if (configJson != null) {
      return jsonDecode(configJson);
    }
    return {};
  }

  Future<void> saveConfigurations(Map<String, dynamic> config) async {
    await _initPrefs();
    String configJson = jsonEncode(config);
    await _prefs?.setString('appConfig', configJson);
  }

  Future<dynamic> getConfigByKey(String key) async {
    await _initPrefs();
    String? configJson = _prefs?.getString('appConfig');
    if (configJson != null) {
      Map<String, dynamic> config = jsonDecode(configJson);
      return config[key];
    }
    return null;
  }
}
