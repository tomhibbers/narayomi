import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/library_page.dart';
import 'pages/updates_page.dart';
import 'pages/browse_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true; // Load saved theme
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  static void setTheme(BuildContext context, bool isDark) async {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.toggleTheme(isDark);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.grey[850],
              appBarTheme: const AppBarTheme(backgroundColor: Colors.black87),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.black87,
                selectedItemColor: Colors.cyan,
                unselectedItemColor: Colors.white70,
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.all(
                    Colors.cyan), // ✅ Switch button color
                trackColor: WidgetStateProperty.all(
                    Colors.cyan.withAlpha(128)), // ✅ Semi-transparent track
                overlayColor: WidgetStateProperty.all(
                    Colors.white60), // ✅ Restores the subtle border effect
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: AppBarTheme(
                  backgroundColor:
                      Colors.grey[300]), // ✅ Softer gray for app bar
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor:
                    Colors.grey[300], // ✅ Softer gray for bottom nav
                selectedItemColor: Colors.teal,
                unselectedItemColor: Colors.black54,
              ),
            ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 3 ? 'Settings' : 'Flutter App'),
        ),
        body: [
          LibraryPage(),
          UpdatesPage(),
          BrowsePage(),
          SettingsPage(),
        ][_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.library_books), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Updates'),
            BottomNavigationBarItem(
                icon: Icon(Icons.browse_gallery), label: 'Browse'),
            BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: 'More'),
          ],
        ),
      ),
    );
  }
}
