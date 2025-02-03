import 'package:flutter/material.dart';

class ReadingTopBar extends StatelessWidget {
  final String title;
  final bool isVisible;

  const ReadingTopBar({super.key, required this.title, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      top: isVisible ? 0 : -(kToolbarHeight + statusBarHeight), // ✅ Move above view when hidden
      left: 0,
      right: 0,
      child: Container(
        height: kToolbarHeight + statusBarHeight, // ✅ AppBar + Status Bar
        padding: EdgeInsets.only(top: statusBarHeight), // ✅ Prevent text from touching status icons
        color: Colors.black.withOpacity(0.85),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
