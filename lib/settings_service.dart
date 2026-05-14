import 'package:shared_preferences/shared_preferences.dart';
class SettingsService {
    static const String _filterKey = "selected_filter";
    static Future<void> saveSelectedFilter(String filter) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_filterKey, filter);
  }
  static Future<String> loadSelectedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_filterKey) ?? "wszystkie";
  }
}