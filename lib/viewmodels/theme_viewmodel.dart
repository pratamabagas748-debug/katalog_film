import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final PrefsService _prefsService = PrefsService();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeViewModel() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await _prefsService.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefsService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }
}
