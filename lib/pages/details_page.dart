import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/providers/publication_details_provider.dart';
import 'package:narayomi/providers/publication_provider.dart';
import 'package:narayomi/widgets/details/details_header.dart';
import 'package:narayomi/widgets/details/genres_component.dart';
import 'package:narayomi/widgets/details/expandable_description.dart';
import 'package:narayomi/widgets/details/action_buttons.dart';
import 'package:narayomi/widgets/details/chapters_component.dart';

class DetailsPage extends ConsumerStatefulWidget {
  final Publication publication;

  const DetailsPage({super.key, required this.publication});

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final pubBox = await Hive.openBox<Publication>('library_v3');
      final normalizedId = widget.publication.id.trim().toLowerCase();

      if (!pubBox.containsKey(normalizedId)) {
        // ✅ If not in library, fetch full details
        ref
            .read(publicationDetailsProvider.notifier)
            .refreshPublication(widget.publication);
      } else {
        // ✅ Load from cache if available
        ref
            .read(publicationDetailsProvider.notifier)
            .loadPublicationDetails(widget.publication);
      }
    });
  }

  void refreshLibrary() {
    ref.invalidate(publicationProvider); // ✅ Force the library list to refresh
  }

  @override
  Widget build(BuildContext context) {
    final details =
        ref.watch(publicationDetailsProvider)[widget.publication.id];

    return Scaffold(
      body: details == null || details.isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // ✅ Show loading indicator while fetching
          : CustomScrollView(
              slivers: [
                DetailsHeader(
                  publication: details.publication,
                  scrollOffset: 0,
                  onRefresh: () => ref
                      .read(publicationDetailsProvider.notifier)
                      .refreshPublication(details.publication),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        ActionButtons(
                          publication: details.publication,
                          onLibraryChange: refreshLibrary,
                        ),
                        SizedBox(height: 16),
                        ExpandableDescription(
                          description: details.publication.description ??
                              "No description available.",
                        ),
                        SizedBox(height: 16),
                        GenresComponent(
                            genres: details.publication.genres ?? []),
                        SizedBox(height: 16),
                        ChaptersComponent(
                            chapters: details.chapters,
                            publication: details.publication),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
