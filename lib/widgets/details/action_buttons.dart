import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            Text("Add to Library", style: TextStyle(color: Colors.white)),
          ],
        ),
        Column(
          children: [
            Icon(Icons.track_changes, color: Colors.white),
            Text("Tracking", style: TextStyle(color: Colors.white)),
          ],
        ),
        Column(
          children: [
            Icon(Icons.language, color: Colors.yellow),
            Text("WebView", style: TextStyle(color: Colors.yellow)),
          ],
        ),
      ],
    );
  }
}
