import 'package:hive/hive.dart';

part 'tracked_series.g.dart'; // Generated with build_runner

@HiveType(typeId: 5)
class TrackedSeries extends HiveObject {
  @HiveField(0)
  final int id; // MangaUpdates series ID

  @HiveField(1)
  final String publicationId; // Local publication ID from your library

  @HiveField(2)
  final int listId; // API list ID (e.g., 0 = Reading, 1 = Completed)

  @HiveField(3)
  final int currentChapter;

  @HiveField(4)
  final int score;

  TrackedSeries({
    required this.id,
    required this.publicationId,
    required this.listId,
    required this.currentChapter,
    required this.score,
  });
}
