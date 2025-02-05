import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/pages/webview_page.dart';

class ActionButtons extends StatefulWidget {
  final Publication publication;
  final VoidCallback onTrack;

  const ActionButtons({
    super.key,
    required this.publication,
    required this.onTrack,
  });

  @override
  _ActionButtonsState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool isInLibrary = false;

  @override
  void initState() {
    super.initState();
    _checkIfInLibrary();
  }

  void _checkIfInLibrary() async {
    var box = await Hive.openBox<Publication>('library_v3');
    setState(() {
      isInLibrary = box.containsKey(widget.publication.id);
    });
  }

  void _toggleLibrary() async {
    var box = await Hive.openBox<Publication>('library_v3');

    if (isInLibrary) {
      box.delete(widget.publication.id);
      Fluttertoast.showToast(
          msg: "Removed from Library", gravity: ToastGravity.BOTTOM);
    } else {
      box.put(widget.publication.id, widget.publication);
      Fluttertoast.showToast(
          msg: "Added to Library", gravity: ToastGravity.BOTTOM);
    }

    setState(() {
      isInLibrary = !isInLibrary;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor =
        Theme.of(context).colorScheme.secondary; // ✅ Theme-based color

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            onTap: _toggleLibrary,
            icon: isInLibrary
                ? Icons.favorite
                : Icons.favorite_border, // ✅ Outlined -> Filled
            label:
                isInLibrary ? "In Library" : "Add to Library", // ✅ Dynamic text
            isSelected: isInLibrary,
            accentColor: accentColor,
          ),
          _buildButton(
            onTap: widget.onTrack,
            icon: Icons.sync_outlined,
            label: "Tracking",
            isSelected: false,
            accentColor: accentColor,
          ),
          _buildButton(
            onTap: () {
              if (widget.publication.url != null &&
                  widget.publication.url!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      url: widget.publication.url!,
                      publicationTitle: widget.publication.title,
                    ),
                  ),
                );
              } else {
                Fluttertoast.showToast(
                  msg: "No webpage available",
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            icon: Icons.public_outlined,
            label: "Web",
            isSelected: false,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color accentColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? accentColor
                    : Theme.of(context).colorScheme.onBackground), // ✅ Uses theme color when selected
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                  color: isSelected ? accentColor : Theme.of(context).colorScheme.onBackground, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
