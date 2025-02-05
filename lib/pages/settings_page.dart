import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        // backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Select Theme:"),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: themeProvider.themeName,
              dropdownColor: Theme.of(context).colorScheme.background,
              icon: Icon(Icons.palette,
                  color: Theme.of(context).colorScheme.secondary),
              items: AppThemes.themeMap.keys.map((themeKey) {
                return DropdownMenuItem(
                  value: themeKey,
                  child: Text(themeKey,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                );
              }).toList(),
              onChanged: (themeKey) {
                if (themeKey != null) {
                  themeProvider.setTheme(themeKey); // 🔥 Apply the new theme
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
