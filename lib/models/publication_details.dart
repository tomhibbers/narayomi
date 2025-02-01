import 'package:narayomi/models/publication.dart';
import 'package:narayomi/models/chapter.dart';

class PublicationDetails {
  final Publication publication;
  final List<Chapter> chapters;

  PublicationDetails({
    required this.publication,
    required this.chapters,
  });
}