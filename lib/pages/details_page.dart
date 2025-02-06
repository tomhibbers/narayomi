import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/providers/publication_details_provider.dart';
import 'package:narayomi/widgets/details/details_header.dart';
import 'package:narayomi/widgets/details/genres_component.dart';
import 'package:narayomi/widgets/details/publication_info.dart';
import 'package:narayomi/widgets/details/expandable_description.dart';
import 'package:narayomi/widgets/details/action_buttons.dart';
import 'package:narayomi/widgets/details/chapters_component.dart';

class DetailsPage extends ConsumerWidget {
  final Publication publication; // ✅ Pass full publication now

  const DetailsPage({super.key, required this.publication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(publicationDetailsProvider(publication));

    return Scaffold(
      body: details.isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // ✅ Show loading indicator while fetching
          : CustomScrollView(
              slivers: [
                DetailsHeader(
                  publication: details.publication,
                  scrollOffset: 0,
                  onRefresh: () => ref
                      .read(publicationDetailsProvider(publication).notifier)
                      .refreshPublication(),
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
                          onTrack: () {
                            // TODO: Implement tracking
                          },
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
