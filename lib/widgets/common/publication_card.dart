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

        /// ✅ Ensure all required fields are set before passing to DetailsPage
        final safePublication = Publication(
          id: publication.id,
          title: publication.title.isNotEmpty
              ? publication.title
              : "Unknown Title",
          author: publication.author?.isNotEmpty == true
              ? publication.author!
              : "Unknown Author",
          status: publication.status?.isNotEmpty == true
              ? publication.status!
              : "Unknown Status",
          thumbnailUrl:
              publication.thumbnailUrl ?? "", // ✅ Ensure it’s non-null
          url: publication.url,
          type: publication.type,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
                publication: safePublication), // ✅ Pass safePublication
          ),
        );
      },
      child: isGridView
          ? _buildGridView(context, theme)
          : _buildListView(context, theme),
    );
  }

  /// ✅ Grid View Layout
  Widget _buildGridView(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          /// ✅ Cover Image (Handles Null Case)
          SizedBox(
            height: 140,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: publication.thumbnailUrl != null &&
                        publication.thumbnailUrl!.isNotEmpty
                    ? Image.network(
                        publication.thumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        child: Icon(Icons.image,
                            color: theme.colorScheme.onBackground, size: 40),
                      ),
              ),
            ),
          ),
          SizedBox(height: 4),

          /// ✅ Title
          Container(
            height: 32,
            padding: EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            child: Text(
              publication.title.isNotEmpty
                  ? publication.title
                  : "Unknown Title",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ List View Layout
  Widget _buildListView(BuildContext context, ThemeData theme) {
    return ListTile(
      tileColor: theme.colorScheme.surface,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: publication.thumbnailUrl != null &&
                  publication.thumbnailUrl!.isNotEmpty
              ? Image.network(
                  publication.thumbnailUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  child: Icon(Icons.image,
                      color: theme.colorScheme.onBackground, size: 40),
                ),
        ),
      ),
      title: Text(
        publication.title.isNotEmpty ? publication.title : "Unknown Title",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
