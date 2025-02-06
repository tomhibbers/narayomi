import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:narayomi/providers/publication_details_provider.dart';
import 'package:narayomi/providers/publication_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart'; // ✅ Import Hive
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';

class SettingsPage extends riverpod.ConsumerWidget {
  const SettingsPage({super.key});

  void _clearDatabase(BuildContext context, riverpod.WidgetRef ref) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Database"),
        content: Text(
            "Are you sure you want to delete all saved data? This cannot be undone."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Yes, Clear"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Hive.deleteFromDisk(); // 🔥 Clears all stored data

      // 🔄 Invalidate cached Riverpod data
      ref.invalidate(publicationProvider); // Replace with actual provider
      ref.invalidate(publicationDetailsProvider); // Replace with actual provider

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Database cleared! Restart or refresh the app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  themeProvider.setTheme(themeKey);
                }
              },
            ),
            const SizedBox(height: 30), // 🔼 Added space before new button
            Divider(), // ✅ UI separation
            const SizedBox(height: 10),
            Text("Developer Tools",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _clearDatabase(context, ref),
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text("Clear Hive Database"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // 🔥 Warning color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
