class MangaUpdatesUserStatus {
  final int seriesId;
  final int volume;
  final int chapter;

  MangaUpdatesUserStatus(
      {required this.seriesId, required this.volume, required this.chapter});

  Map<String, dynamic> toJson() {
    return {
      "series_id": seriesId,
      "status": {"volume": volume, "chapter": chapter},
    };
  }
}
