import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.lightTheme;
  String _themeName = "Light";

  ThemeData get currentTheme => _currentTheme;
  String get themeName => _themeName;

  ThemeProvider() {
    _loadThemeFromPrefs(); // ✅ Load theme when the provider is created
  }

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('selectedTheme') ?? "Light";
    if (AppThemes.themeMap.containsKey(savedTheme)) {
      _currentTheme = AppThemes.themeMap[savedTheme]!;
      _themeName = savedTheme;
      notifyListeners();
    }
  }

  void setTheme(String themeKey) async {
    if (AppThemes.themeMap.containsKey(themeKey)) {
      _currentTheme = AppThemes.themeMap[themeKey]!;
      _themeName = themeKey;
      notifyListeners();

      // ✅ Save theme selection
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedTheme', themeKey);
    }
  }
}
