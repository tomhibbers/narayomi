import 'package:flutter/material.dart';
import 'package:narayomi/models/content_type.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/publication_details.dart';
import 'package:narayomi/services/comick_scraper.dart';
import 'package:narayomi/services/ranobes_scraper.dart';
import 'package:narayomi/widgets/details/details_header.dart'; // ✅ Import the new widget
import 'package:narayomi/widgets/details/genres_component.dart';
import 'package:narayomi/widgets/details/publication_info.dart';
import 'package:narayomi/widgets/details/expandable_description.dart';
import 'package:narayomi/widgets/details/action_buttons.dart';
import 'package:narayomi/widgets/details/chapters_component.dart';

class DetailsPage extends StatefulWidget {
  final Publication publication;

  const DetailsPage({super.key, required this.publication})
      : assert(publication != null, "Publication cannot be null");

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Publication? publication;
  List<Chapter> chapters = [];
  bool isLoading = true;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchPublicationDetails();
  }

  Future<void> _fetchPublicationDetails() async {
    if (widget.publication.type == ContentType.Novel) {
      PublicationDetails details =
          await scrapeRaNobesPublicationDetails(widget.publication.url ?? "");

      setState(() {
        publication = details.publication;
        chapters = details.chapters;
        isLoading = false;
      });
    } else {
      PublicationDetails details =
          await scrapeComickPublicationDetails(widget.publication.url ?? "");

      setState(() {
        publication = details.publication;
        chapters = details.chapters;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                setState(() {
                  _scrollOffset = scrollInfo.metrics.pixels;
                });
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  /// ✅ Replacing SliverAppBar with `DetailsHeader`
                  if (publication != null)
                    DetailsHeader(
                      publication: publication!,
                      scrollOffset: _scrollOffset,
                    ),

                  /// ✅ Action Buttons, Description, and Chapters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          if (publication != null)
                            ActionButtons(
                              publication: publication!,
                              onTrack: () {
                                // TODO: Implement track functionality
                              },
                            ),
                          SizedBox(height: 16),
                          ExpandableDescription(
                            description: publication?.description ??
                                "No description available.",
                          ),
                          SizedBox(height: 16),
                          GenresComponent(genres: publication!.genres ?? []),
                          SizedBox(height: 16),
                          ChaptersComponent(
                              chapters: chapters, publication: publication!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
