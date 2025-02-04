import 'package:hive/hive.dart';
import 'content_type.dart'; // Enum

part 'publication.g.dart';

@HiveType(typeId: 1)
class Publication extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) ContentType type;
  @HiveField(3) String? url;
  @HiveField(4) String? status;
  @HiveField(5) String? rating;
  @HiveField(6) int? catalogId;
  @HiveField(7) List<String>? categories;
  @HiveField(8) DateTime? dateAdded;
  @HiveField(9) String? artist;
  @HiveField(10) String? author;
  @HiveField(11) String? description;
  @HiveField(12) List<String>? genres;
  @HiveField(13) String? thumbnailUrl;
  @HiveField(14) DateTime? lastModifiedAt;

  Publication({
    required this.id,
    required this.title,
    required this.type,
    this.url,
    this.status,
    this.rating,
    this.catalogId,
    this.categories,
    this.dateAdded,
    this.artist,
    this.author,
    this.description,
    this.genres,
    this.thumbnailUrl,
    this.lastModifiedAt,
  });
}
