class MangaUpdatesSeries {
  final String seriesId;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> genres;
  final String status;

  MangaUpdatesSeries({
    required this.seriesId,
    required this.title,
    this.description = '',
    this.imageUrl = '',
    this.genres = const [],
    this.status = '',
  });

  factory MangaUpdatesSeries.fromJson(Map<String, dynamic> json) {
    final record = json['record'] ?? {};
    final image =
        record['image']?['url']?['thumb']; // Use the thumbnail if available
    final genreList = record['genres'] as List<dynamic>?;

    return MangaUpdatesSeries(
      seriesId:
          record['series_id']?.toString() ?? 'N/A', // Fallback to 'N/A' if null
      title: record['title'] ?? 'Unknown Title',
      description: record['description'] ?? '',
      imageUrl:
          image ?? '', // Default to an empty string if the image is missing
      genres: genreList != null
          ? genreList
              .map((g) => g['genre']?.toString() ?? '')
              .where((g) => g.isNotEmpty)
              .toList()
          : [],
      status: record['type'] ?? '',
    );
  }
}
