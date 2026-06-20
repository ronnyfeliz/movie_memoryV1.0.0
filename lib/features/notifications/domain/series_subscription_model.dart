class SeriesSubscription {
  final String id;
  final int tmdbId;
  final String title;
  final String posterPath;
  final String mediaType;
  final DateTime subscribedAt;
  final bool notifyEpisodes;
  final bool notifySeasons;
  final bool notifyUpdates;

  SeriesSubscription({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.posterPath,
    required this.mediaType,
    required this.subscribedAt,
    this.notifyEpisodes = true,
    this.notifySeasons = true,
    this.notifyUpdates = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'tmdbId': tmdbId,
      'title': title,
      'posterPath': posterPath,
      'mediaType': mediaType,
      'subscribedAt': subscribedAt.toIso8601String(),
      'notifyEpisodes': notifyEpisodes,
      'notifySeasons': notifySeasons,
      'notifyUpdates': notifyUpdates,
    };
  }

  factory SeriesSubscription.fromMap(String id, Map<String, dynamic> map) {
    return SeriesSubscription(
      id: id,
      tmdbId: map['tmdbId'] ?? 0,
      title: map['title'] ?? '',
      posterPath: map['posterPath'] ?? '',
      mediaType: map['mediaType'] ?? 'tv',
      subscribedAt: DateTime.parse(map['subscribedAt'] ?? DateTime.now().toIso8601String()),
      notifyEpisodes: map['notifyEpisodes'] ?? true,
      notifySeasons: map['notifySeasons'] ?? true,
      notifyUpdates: map['notifyUpdates'] ?? true,
    );
  }

  SeriesSubscription copyWith({
    bool? notifyEpisodes,
    bool? notifySeasons,
    bool? notifyUpdates,
  }) {
    return SeriesSubscription(
      id: id,
      tmdbId: tmdbId,
      title: title,
      posterPath: posterPath,
      mediaType: mediaType,
      subscribedAt: subscribedAt,
      notifyEpisodes: notifyEpisodes ?? this.notifyEpisodes,
      notifySeasons: notifySeasons ?? this.notifySeasons,
      notifyUpdates: notifyUpdates ?? this.notifyUpdates,
    );
  }
}
