import 'dart:ui'; // ✅ Import for blur effect
import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/widgets/details/publication_info.dart';

class DetailsHeader extends StatelessWidget {
  final Publication publication;
  final double scrollOffset;
  final VoidCallback onRefresh; // ✅ Accepts the refresh function

  const DetailsHeader({
    Key? key,
    required this.publication,
    required this.scrollOffset,
    required this.onRefresh, // ✅ Ensure it's passed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260, // ✅ Increased to fit image + details
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            /// ✅ Background Image (Blurry)
            Image.network(
              publication.thumbnailUrl ?? "",
              fit: BoxFit.cover,
            ),

            /// ✅ Blur Effect Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // ✅ Blur effect
                child: Container(
                  color: Colors.black.withOpacity(0.3), // ✅ Slight dark overlay for readability
                ),
              ),
            ),

            /// ✅ Title, Author, Status & Cover Image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: PublicationInfo(publication: publication), // ✅ Cover Image Stays Normal
              ),
            ),
          ],
        ),
      ),

      /// ✅ Refresh Button in AppBar
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
