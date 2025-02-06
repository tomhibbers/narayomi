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
    state = box.values.toList(); // Store in memory
  }

  /// ✅ Add a publication to the library (updates memory first, then Hive)
  Future<void> addPublication(Publication publication) async {
    final box = await Hive.openBox<Publication>('library_v3');
    await box.put(publication.id, publication);
    state = [...state, publication]; // Update cached state
  }

  /// ✅ Remove a publication from the library (updates memory first, then Hive)
  Future<void> removePublication(String id) async {
    final box = await Hive.openBox<Publication>('library_v3');
    await box.delete(id);
    state = state.where((pub) => pub.id != id).toList(); // Update state
  }
}
