import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import to access `MyApp.setTheme`

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true; // ✅ Default value to prevent LateInitializationError

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Load saved theme preference
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true; // ✅ Fallback to default
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });

    MyApp.setTheme(context, value); // Notify MyApp to update theme
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SwitchListTile(
          title: const Text("Dark Mode"),
          value: _isDarkMode, // ✅ No more LateInitializationError
          onChanged: _toggleTheme,
        ),
      ],
    );
  }
}
