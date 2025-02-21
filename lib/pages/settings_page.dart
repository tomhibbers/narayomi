import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:narayomi/providers/publication_details_provider.dart';
import 'package:narayomi/providers/publication_provider.dart';
import 'package:narayomi/utils/secure_storage.dart';
import 'package:narayomi/widgets/common/toast_utils.dart';
import 'package:narayomi/widgets/settings/mangaupdates_login_form.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:hive/hive.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final credentials = await SecureStorage.getCredentials();

    setState(() {
      _isLoggedIn = credentials['token'] != null;
    });
  }

  Future<void> _connect(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Connect to MangaUpdates"),
          content: MangaUpdatesLoginForm(onSuccess: () {
            Navigator.pop(context); // Close the dialog on success
            _checkLoginStatus(); // Update the button state
            ToastUtils.showToast(
                context, "Successfully connected to MangaUpdates!");
          }),
        );
      },
    );
  }

  Future<void> _disconnect(BuildContext context) async {
    await SecureStorage.clearCredentials();
    setState(() {
      _isLoggedIn = false;
    });
    ToastUtils.showToast(context, "Disconnected from MangaUpdates.");
  }

  void _clearDatabase(BuildContext context) async {
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
      await Hive.deleteFromDisk();
      ref.invalidate(publicationProvider); // Use ref from ConsumerState
      ref.invalidate(publicationDetailsProvider);

      ToastUtils.showToast(
          context, "Database cleared! Restart or refresh the app.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = legacy.Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
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
                  child: Text(
                    themeKey,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                );
              }).toList(),
              onChanged: (themeKey) {
                if (themeKey != null) {
                  themeProvider.setTheme(themeKey);
                }
              },
            ),
            const SizedBox(height: 30),
            Divider(),
            const SizedBox(height: 10),
            Text("Developer Tools",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _clearDatabase(context),
              icon: Icon(Icons.delete,
                  color: Theme.of(context).colorScheme.onError),
              label: Text("Clear Hive Database",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 30),
            Divider(),
            const SizedBox(height: 10),
            Text("MangaUpdates Integration",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              onPressed: _isLoggedIn
                  ? () => _disconnect(context)
                  : () => _connect(context),
              child: Text(
                  _isLoggedIn
                      ? "Disconnect from MangaUpdates"
                      : "Connect to MangaUpdates",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
            ),
          ],
        ),
      ),
    );
  }
}
