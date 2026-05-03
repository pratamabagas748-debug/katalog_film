import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _themeKey = 'isDarkMode';

  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default false (Light mode)
  }
}
