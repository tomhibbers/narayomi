import 'package:flutter/material.dart';
import 'pages/library_page.dart';
import 'pages/updates_page.dart';
import 'pages/browse_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LibraryPage(),
    UpdatesPage(),
    BrowsePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[850], // Dark gray for main content
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black87, // Darker app bar
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black87, // Darker bottom nav
          selectedItemColor: Colors.tealAccent, // Highlighted item color
          unselectedItemColor: Colors.white70, // Dimmed for inactive items
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 3
              ? 'Settings'
              : 'NaraYomi'), // Change title when on Settings Page
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.update_outlined), label: 'Updates'),
            BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined), label: 'Browse'),
            BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz), label: 'More'),
          ],
        ),
      ),
    );
  }
}
