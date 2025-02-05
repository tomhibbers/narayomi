import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/pages/details_page.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;
  final bool isGridView;

  const PublicationCard({
    Key? key,
    required this.publication,
    required this.isGridView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅ Use Theme

    return GestureDetector(
      onTap: () {
        print("Navigating to: ${publication.title}");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(publication: publication),
          ),
        );
      },
      child: isGridView
          ? _buildGridView(context, theme)
          : _buildListView(context, theme),
    );
  }

  /// ✅ Grid View Layout - Now Uses Theme Colors
  Widget _buildGridView(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // ✅ Background uses theme color
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ✅ Cover Image
          SizedBox(
            height: 140,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: publication.thumbnailUrl != null
                    ? Image.network(
                        publication.thumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: theme.colorScheme.onSurface.withOpacity(
                            0.2)), // ✅ Placeholder uses theme color
              ),
            ),
          ),
          SizedBox(height: 4),

          /// ✅ Title - Now Uses Theme Text Colors
          Container(
            height: 32,
            padding: EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            child: Text(
              publication.title ?? "Unknown Title",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface, // ✅ Text uses theme color
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ List View Layout - Now Uses Theme Colors
  Widget _buildListView(BuildContext context, ThemeData theme) {
    return ListTile(
      tileColor: theme.colorScheme.surface, // ✅ List tile uses theme background
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: publication.thumbnailUrl != null
              ? Image.network(
                  publication.thumbnailUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.2)), // ✅ Placeholder uses theme
        ),
      ),
      title: Text(
        publication.title ?? "Unknown Title",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface, // ✅ Text uses theme color
        ),
      ),
    );
  }
}
