class MangaUpdatesListSeries {
  final int seriesId;
  final String title;
  final int listId;
  final String? listType;
  final int volume;
  final int chapter;
  final int? priority;
  final DateTime timeAdded;

  MangaUpdatesListSeries({
    required this.seriesId,
    required this.title,
    required this.listId,
    this.listType,
    required this.volume,
    required this.chapter,
    this.priority,
    required this.timeAdded,
  });

  factory MangaUpdatesListSeries.fromJson(Map<String, dynamic> json) {
    final series = json['series'] ?? {};
    final status = json['status'] ?? {};
    final timeAdded = json['time_added']?['as_rfc3339'];

    return MangaUpdatesListSeries(
      seriesId: series['id'],
      title: series['title'] ?? '',
      listId: json['list_id'],
      listType: json['list_type'],
      volume: status['volume'] ?? 0,
      chapter: status['chapter'] ?? 0,
      priority: json['priority'],
      timeAdded: timeAdded != null ? DateTime.parse(timeAdded) : DateTime.now(),
    );
  }
}
