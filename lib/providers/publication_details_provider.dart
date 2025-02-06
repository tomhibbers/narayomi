import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:narayomi/models/content_type.dart';
import '../models/publication.dart';
import '../models/chapter.dart';
import '../models/publication_details.dart';
import '../services/comick_scraper.dart';
import '../services/ranobes_scraper.dart';
import 'dart:developer' as dev;

/// ✅ Provider for Cached Publication Details & Chapters
final publicationDetailsProvider = StateNotifierProvider.family<
    PublicationDetailsNotifier,
    PublicationDetailsState,
    Publication>((ref, pub) {
  return PublicationDetailsNotifier(pub);
});

/// ✅ State Model to Hold Cached Details
class PublicationDetailsState {
  final Publication publication;
  final List<Chapter> chapters;
  final bool isLoading;

  PublicationDetailsState(
      {required this.publication,
      this.chapters = const [],
      this.isLoading = true});
}

/// ✅ Manages Cached Publication Details & Chapters
class PublicationDetailsNotifier
    extends StateNotifier<PublicationDetailsState> {
  final Publication publication;

  PublicationDetailsNotifier(this.publication)
      : super(PublicationDetailsState(publication: publication)) {
    loadPublicationDetails(); // ✅ Load only if it exists in Hive
  }

  /// ✅ Load from Hive Only if Already in Library
  Future<void> loadPublicationDetails() async {
    final pubBox = await Hive.openBox<Publication>('library_v3');
    final chapterBox = await Hive.openBox<Chapter>('chapters');

    final normalizedId = publication.id.trim().toLowerCase();

    var cachedPublication = pubBox.get(normalizedId); // ✅ Corrected Hive lookup

    /// ✅ Fetch stored chapters correctly
    var storedChapters = chapterBox.values
        .where(
          (c) =>
              c.normalizedPublicationId?.trim().toLowerCase() == normalizedId,
        )
        .toList();

    dev.log(
        "📌 Loaded ${storedChapters.length} cached chapters for: ${publication.title}",
        name: "CHAPTER_CACHE");

    /// ✅ If chapters exist, load them into state **before refreshing**
    if (cachedPublication != null && storedChapters.isNotEmpty) {
      state = PublicationDetailsState(
          publication: cachedPublication,
          chapters: storedChapters,
          isLoading: false);
      return; // ✅ Stop execution here if we found cached data
    }

    /// ✅ If no cached data, fetch fresh details
    dev.log("📌 No cached chapters found, fetching fresh details...",
        name: "CHAPTER_UPDATE");
    await refreshPublication(skipCache: false);
  }

  /// ✅ Fetch Fresh Chapters (Only Add Missing Ones)
  Future<void> refreshPublication({bool skipCache = false}) async {
    final normalizedId = state.publication.id.trim().toLowerCase();

    state = PublicationDetailsState(
        publication: state.publication,
        chapters: state.chapters,
        isLoading: true);

    PublicationDetails details;
    if (state.publication.type == ContentType.Novel) {
      details =
          await scrapeRaNobesPublicationDetails(state.publication.url ?? "");
    } else {
      details =
          await scrapeComickPublicationDetails(state.publication.url ?? "");
    }

    final pubBox = await Hive.openBox<Publication>('library_v3');
    final chapterBox = await Hive.openBox<Chapter>('chapters');

    if (!skipCache) {
      await pubBox.put(normalizedId, details.publication);
    }

    // ✅ Fetch all stored chapters for this publication
    final storedChapterIds = chapterBox.values
        .where((c) => c.normalizedPublicationId == normalizedId)
        .map((c) => c.id)
        .toSet();

    dev.log("📌 Stored Chapter IDs for $normalizedId: $storedChapterIds",
        name: "CHAPTER_CACHE");

    // ✅ Compare by `id` instead of relying on `containsKey`
    List<Chapter> newChapters = details.chapters
        .where(
          (newChap) => !storedChapterIds
              .contains(newChap.id), // ✅ Check against stored IDs
        )
        .toList();

    dev.log(
        "📌 New Chapters to be saved for ${state.publication.title}: ${newChapters.map((c) => c.id).toList()}",
        name: "CHAPTER_SAVE");

    for (var chapter in newChapters) {
      chapter.normalizedPublicationId =
          normalizedId; // ✅ Store correct publication ID
      await chapterBox.put(
          chapter.id, chapter); // ✅ Store new chapters correctly
    }

    dev.log(
        "✅ Saved ${newChapters.length} new chapters for: ${state.publication.title}",
        name: "CHAPTER_SAVE");

    // ✅ Always reload chapters from Hive to update the UI correctly
    final storedChapters = chapterBox.values
        .where(
          (c) => c.normalizedPublicationId == normalizedId,
        )
        .toList();

    state = PublicationDetailsState(
      publication: details.publication,
      chapters:
          storedChapters, // ✅ Load stored chapters instead of relying on `state`
      isLoading: false,
    );

    dev.log(
        "✅ Updated state for publication: ${state.publication.title} (Total Chapters: ${state.chapters.length})",
        name: "CHAPTER_UPDATE");
  }
}
