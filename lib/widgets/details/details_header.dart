import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/widgets/details/publication_info.dart';

class DetailsHeader extends StatelessWidget {
  final Publication publication;
  final double scrollOffset;

  const DetailsHeader({
    Key? key,
    required this.publication,
    required this.scrollOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double headerHeight = isLandscape ? 200.0 : 250.0; // ✅ Reduced height

    return SliverAppBar(
      expandedHeight: headerHeight, // ✅ Adjusted height dynamically
      pinned: true,
      title: Opacity(
        opacity: scrollOffset > 150 ? 1.0 : 0.0, // ✅ Adjust fade-in threshold
        child: Text(
          publication.title ?? "Loading...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            /// Thumbnail Background (Blurred)
            publication.thumbnailUrl != null
                ? Image.network(
                    publication.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Theme.of(context).colorScheme.background,
                  ), // Placeholder for missing image

            /// Blur Effect Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color:
                      Theme.of(context).colorScheme.background.withOpacity(0.3),
                ),
              ),
            ),

            /// Publication Info (Title, Artist, etc.) - Moved lower
            Positioned(
              left: 16,
              right: 16,
              bottom: 25, // ✅ Adjusted position to save space
              child: PublicationInfo(publication: publication),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(icon: Icon(Icons.download_outlined), onPressed: () {}),
        IconButton(icon: Icon(Icons.filter_list_outlined), onPressed: () {}),
        IconButton(icon: Icon(Icons.more_vert_outlined), onPressed: () {}),
      ],
    );
  }
}
