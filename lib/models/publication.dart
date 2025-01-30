import 'package:hive/hive.dart';
import 'content_type.dart'; // Enum

part 'publication.g.dart';

@HiveType(typeId: 1)
class Publication extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) ContentType type;
  @HiveField(3) int typeId;
  @HiveField(4) String? url;
  @HiveField(5) String? status;
  @HiveField(6) String? rating;
  @HiveField(7) int? catalogId;
  @HiveField(8) List<String>? categories;
  @HiveField(9) DateTime? dateAdded;
  @HiveField(10) String? artist;
  @HiveField(11) String? author;
  @HiveField(12) String? description;
  @HiveField(13) List<String>? genres;
  @HiveField(14) String? thumbnailUrl;
  @HiveField(15) DateTime? lastModifiedAt;

  Publication({
    required this.id,
    required this.title,
    required this.type,
    required this.typeId,
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
