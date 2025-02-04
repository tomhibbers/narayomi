import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/publication_details.dart';
import 'package:narayomi/services/ranobes_scraper.dart';
import 'package:narayomi/widgets/details/publication_info.dart';
import 'package:narayomi/widgets/details/expandable_description.dart';
import 'package:narayomi/widgets/details/action_buttons.dart';
import 'package:narayomi/widgets/details/chapters_component.dart';

class DetailsPage extends StatefulWidget {
  final Publication publication;

  const DetailsPage({super.key, required this.publication})
      : assert(
            publication != null, "Publication cannot be null"); // ✅ Debugging

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
    PublicationDetails details =
        await scrapePublicationDetails(widget.publication?.url ?? "");

    setState(() {
      publication = details.publication;
      chapters = details.chapters;
      isLoading = false;
    });
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
                  // ✅ SliverAppBar with Blurred Background + Scroll-Aware Title
                  SliverAppBar(
                    expandedHeight: 350.0,
                    pinned: true,
                    title: Opacity(
                      opacity: _scrollOffset > 200 ? 1.0 : 0.0,
                      child: Text(
                        publication?.title ?? "Loading...",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          publication?.thumbnailUrl != null
                              ? Image.network(
                                  publication!.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[800]), // ✅ Placeholder
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                  color: Colors.black.withOpacity(0.3)),
                            ),
                          ),
                          if (publication !=
                              null) // ✅ Ensure publication is available
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 40,
                              child: PublicationInfo(publication: publication!),
                            ),
                        ],
                      ),
                    ),
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context)),
                    actions: [
                      IconButton(
                          icon: Icon(Icons.download_outlined), onPressed: () {}),
                      IconButton(icon: Icon(Icons.filter_list_outlined), onPressed: () {}),
                      IconButton(icon: Icon(Icons.more_vert_outlined), onPressed: () {}),
                    ],
                  ),

                  // ✅ Action Buttons, Expandable Description, and Chapters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          if (publication !=
                              null) // ✅ Check before using publication
                            ActionButtons(
                              publication: publication!,
                              onTrack: () {
                                // TODO: Implement track functionality
                              },
                            ),
                          SizedBox(height: 16),
                          ExpandableDescription(
                              description: publication?.description ??
                                  "No description available."),
                          SizedBox(height: 16),
                          ChaptersComponent(chapters: chapters),
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
