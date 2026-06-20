class WatchHistoryEntry {
  final String id;
  final int tmdbId;
  final int? imdbId;
  final String type;
  final String title;
  final String? posterPath;
  final int? season;
  final int? episode;
  final double progress;
  final double? totalDuration;
  final double percentage;
  final DateTime lastWatched;

  WatchHistoryEntry({
    required this.id,
    required this.tmdbId,
    this.imdbId,
    required this.type,
    required this.title,
    this.posterPath,
    this.season,
    this.episode,
    required this.progress,
    this.totalDuration,
    required this.percentage,
    required this.lastWatched,
  });

  String get seasonEpisodeLabel {
    if (season != null && episode != null) {
      return 'S${season!} · E${episode!.toString().padLeft(2, '0')}';
    }
    return '';
  }

  String get timeRemaining {
    if (totalDuration == null || totalDuration! <= 0) return '';
    final remaining = totalDuration! - progress;
    if (remaining <= 0) return '';
    final minutes = (remaining / 60).round();
    if (minutes >= 60) {
      return '${minutes ~/ 60}h ${minutes % 60}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'tmdbId': tmdbId,
      'imdbId': imdbId,
      'type': type,
      'title': title,
      'posterPath': posterPath ?? '',
      'season': season,
      'episode': episode,
      'progress': progress,
      'totalDuration': totalDuration,
      'percentage': percentage,
      'lastWatched': lastWatched.toIso8601String(),
    };
  }

  factory WatchHistoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return WatchHistoryEntry(
      id: id,
      tmdbId: map['tmdbId'] ?? 0,
      imdbId: map['imdbId'] as int?,
      type: map['type'] ?? 'movie',
      title: map['title'] ?? '',
      posterPath: map['posterPath'] as String?,
      season: map['season'] as int?,
      episode: map['episode'] as int?,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      totalDuration: (map['totalDuration'] as num?)?.toDouble(),
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      lastWatched: DateTime.tryParse(map['lastWatched'] ?? '') ?? DateTime.now(),
    );
  }
}
