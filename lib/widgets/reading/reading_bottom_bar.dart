import 'package:flutter/material.dart';
import 'dart:developer';

class ReadingBottomBar extends StatelessWidget {
  final bool isVisible;

  const ReadingBottomBar({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      bottom: isVisible ? 0 : -80, // Moves out of view instead of affecting scroll
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () {
                log("📜 Chapter List clicked");
                // TODO: Implement chapter list popup
              },
            ),
            IconButton(
              icon: Icon(Icons.language, color: Colors.white),
              onPressed: () {
                log("🌐 View Original Webpage clicked");
                // TODO: Implement open webview
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                log("⚙️ Reader Settings clicked");
                // TODO: Implement reader settings popup
              },
            ),
          ],
        ),
      ),
    );
  }
}
