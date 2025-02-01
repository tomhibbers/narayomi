import 'package:flutter/material.dart';

class DetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context), // ✅ Go back
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download_outlined), // ✅ Icon 1 (e.g., Favorite)
          onPressed: () {
            // TODO: Implement logic
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list_outlined), // ✅ Icon 2 (e.g., Download)
          onPressed: () {
            // TODO: Implement logic
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert_outlined), // ✅ Icon 3 (e.g., Share)
          onPressed: () {
            // TODO: Implement logic
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
