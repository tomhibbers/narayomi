import 'package:flutter/material.dart';
import 'package:narayomi/services/ranobes_scraper.dart';
import '../models/publication.dart';
import '../models/chapter.dart';
import '../models/publication_details.dart';
import '../widgets/details_app_bar.dart';
import '../widgets/info_component.dart';
import '../widgets/chapters_component.dart';

class DetailsPage extends StatefulWidget {
  final String publicationUrl;

  const DetailsPage({super.key, required this.publicationUrl});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Publication? publication;
  List<Chapter> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPublicationDetails();
  }

  Future<void> _fetchPublicationDetails() async {
    PublicationDetails details =
        await scrapePublicationDetails(widget.publicationUrl);

    setState(() {
      publication = details.publication;
      chapters = details.chapters;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailsAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoComponent(publication: publication!),
                  SizedBox(height: 20),
                  Text("Chapters",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ChaptersComponent(chapters: chapters),
                ],
              ),
            ),
    );
  }
}
