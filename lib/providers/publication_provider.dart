import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/publication.dart';

/// ✅ Riverpod State Provider for Cached Publications
final publicationProvider =
    StateNotifierProvider<PublicationNotifier, List<Publication>>((ref) {
  return PublicationNotifier();
});

/// ✅ Manages Publications in Memory & Syncs with Hive
class PublicationNotifier extends StateNotifier<List<Publication>> {
  PublicationNotifier() : super([]) {
    loadPublications(); // Load publications into memory when initialized
  }

  /// ✅ Load publications from Hive (Only runs once)
  Future<void> loadPublications() async {
    final box = await Hive.openBox<Publication>('library_v3');
    state = box.values.toList();
  }

  /// ✅ Add a publication to the library (updates memory first, then Hive)
  Future<void> addPublication(Publication publication) async {
    final box = await Hive.openBox<Publication>('library_v3');
    final normalizedId = publication.id.trim().toLowerCase(); // ✅ Normalize ID
    await box.put(normalizedId, publication);

    // ✅ Avoid duplicate entries
    state = [...state.where((p) => p.id != normalizedId), publication];
  }

  /// ✅ Remove a publication from the library (updates memory first, then Hive)
  Future<void> removePublication(String id) async {
    final box = await Hive.openBox<Publication>('library_v3');
    final normalizedId = id.trim().toLowerCase(); // ✅ Normalize ID
    await box.delete(normalizedId);

    state = state.where((pub) => pub.id != normalizedId).toList();
  }
}
