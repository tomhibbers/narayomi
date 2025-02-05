import 'package:flutter/material.dart';

class AppThemes {
  // 🔹 Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.cyan,
      background: Colors.white,
    ),
  );

  // 🔹 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.cyan,
      background: Colors.black,
    ),
  );

  // 🔹 Purple Theme
  static final ThemeData purpleTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurple,
      secondary: Colors.pinkAccent,
      background: Colors.white,
    ),
  );

  // 🔹 Green Theme
  static final ThemeData greenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    colorScheme: ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.teal,
      background: Colors.white,
    ),
  );

  // 🔹 Theme Map for Dropdown Selection
  static final Map<String, ThemeData> themeMap = {
    "Light": lightTheme,
    "Dark": darkTheme,
    "Purple": purpleTheme,
    "Green": greenTheme,
  };
}
