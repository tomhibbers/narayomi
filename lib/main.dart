import 'package:flutter/material.dart';
import 'package:narayomi/models/content_type.dart';
import 'package:narayomi/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/library_page.dart';
import 'pages/updates_page.dart';
import 'pages/browse_page.dart';
import 'pages/settings_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/catalog.dart';
import 'models/publication.dart';
import 'models/chapter.dart';
import 'models/chapter_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ✅ Register All Adapters
  Hive.registerAdapter(CatalogAdapter());
  Hive.registerAdapter(PublicationAdapter());
  Hive.registerAdapter(ChapterAdapter());
  Hive.registerAdapter(ChapterPageAdapter());
  Hive.registerAdapter(ContentTypeAdapter());

  // ✅ Open All Hive Boxes
  await Hive.openBox<Catalog>('catalogs');
  await Hive.openBox<Publication>(
      'library_v3'); // 🔥 Keep 'library_v2' instead of 'publications'
  await Hive.openBox<Chapter>('chapters');
  await Hive.openBox<ChapterPage>('chapter_pages');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // ✅ Get theme
    return MaterialApp(
      theme: themeProvider.currentTheme, // ✅ Apply the theme
      home: Scaffold(
        body: [
          LibraryPage(),
          BrowsePage(),
          UpdatesPage(),
          SettingsPage(),
        ][_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.library_books), label: 'Library'),
            BottomNavigationBarItem(
                icon: Icon(Icons.browse_gallery), label: 'Browse'),
            BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Updates'),
            BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: 'More'),
          ],
        ),
      ),
    );
  }
}
