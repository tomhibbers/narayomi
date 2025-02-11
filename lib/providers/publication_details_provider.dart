import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/chapter.dart';
import 'package:narayomi/models/content_type.dart';
import 'dart:developer' as dev;

import 'package:narayomi/models/publication.dart';
import 'package:narayomi/models/publication_details.dart';
import 'package:narayomi/services/comick_service.dart';
import 'package:narayomi/services/ranobes_service.dart';

/// ✅ Provider for Cached Publication Details & Chapters
final publicationDetailsProvider = StateNotifierProvider<
    PublicationDetailsNotifier, Map<String, PublicationDetailsState>>((ref) {
  return PublicationDetailsNotifier();
});

/// ✅ State Model to Hold Cached Details
class PublicationDetailsState {
  final Publication publication;
  final List<Chapter> chapters;
  final bool isLoading;

  PublicationDetailsState({
    required this.publication,
    this.chapters = const [],
    this.isLoading = true,
  });
}

/// ✅ Manages Cached Publication Details for Multiple Publications
class PublicationDetailsNotifier
    extends StateNotifier<Map<String, PublicationDetailsState>> {
  PublicationDetailsNotifier() : super({});

  /// ✅ Load publication details & chapters (stores them per publication)
  /// ✅ Load publication details & chapters (only using normalizedPublicationId)
  Future<void> loadPublicationDetails(Publication publication) async {
    final pubBox = await Hive.openBox<Publication>('library_v3');
    final chapterBox = await Hive.openBox<Chapter>('chapters');

    final normalizedId =
        publication.id.trim().toLowerCase(); // ✅ Standardize ID
    var cachedPublication = pubBox.get(normalizedId);

    var storedChapters = chapterBox.values
        .where((c) =>
            c.normalizedPublicationId ==
            normalizedId) // ✅ Only using normalizedPublicationId
        .toList();

    dev.log("📌 Loading details for ${publication.title}", name: "DEBUG");
    dev.log("📌 Chapters Found: ${storedChapters.length}", name: "DEBUG");

    // ✅ Preserve existing state while updating only the relevant publication
    state = {
      ...state,
      normalizedId: PublicationDetailsState(
        publication: cachedPublication ?? publication,
        chapters: storedChapters,
        isLoading: false,
      ),
    };
  }

  /// ✅ Fetch Fresh Chapters & Save to Hive (stop using publicationId)
  Future<void> refreshPublication(Publication publication,
      {bool skipCache = false}) async {
    final normalizedId =
        publication.id.trim().toLowerCase(); // ✅ Standardized ID
    final pubBox = await Hive.openBox<Publication>('library_v3');
    final chapterBox = await Hive.openBox<Chapter>('chapters');

    // ✅ Preserve all existing chapters before fetching new ones
    final existingChapters = chapterBox.values
        .where((c) =>
            c.normalizedPublicationId == normalizedId) // ✅ Updated filtering
        .toList();

    dev.log(
        "🔍 Before Refresh | Chapters in Hive (${publication.title}): ${existingChapters.length}",
        name: "DEBUG");

    // ✅ Preserve previous state while marking only the current publication as loading
    state = {
      ...state,
      normalizedId: PublicationDetailsState(
        publication: state[normalizedId]?.publication ?? publication,
        chapters: existingChapters,
        isLoading: true,
      ),
    };

    PublicationDetails details;
    if (publication.type == ContentType.Novel) {
      details = await raNobesPublicationDetails(publication.url ?? "");
    } else {
      details = await comickPublicationDetails(publication.url ?? "");
    }

    // ✅ Always save fetched details to Hive (even if not in library)
    await pubBox.put(normalizedId, details.publication);

    // ✅ Save fetched chapters (ensuring `normalizedPublicationId` is set)
    for (var chapter in details.chapters) {
      chapter.normalizedPublicationId =
          normalizedId; // ✅ Assign normalized ID properly
      chapter.publicationId =
          -1; // ❌ Dummy value, ensuring publicationId is ignored
      await chapterBox.put(chapter.id, chapter);
    }

    // ✅ Reload stored chapters from Hive using only normalizedPublicationId
    final storedChapters = chapterBox.values
        .where((c) =>
            c.normalizedPublicationId == normalizedId) // ✅ Ensure consistency
        .toList();

    dev.log(
        "🔍 After Refresh | Chapters in Hive (${publication.title}): ${storedChapters.length}",
        name: "DEBUG");

    // ✅ Preserve all publications' state while updating the current one
    state = {
      ...state,
      normalizedId: PublicationDetailsState(
        publication: details.publication,
        chapters: storedChapters,
        isLoading: false,
      ),
    };
  }
}
