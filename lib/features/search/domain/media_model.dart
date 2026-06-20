class MediaModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String mediaType;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final int runtime;
  final List<int> genreIds;
  final List<String> genreNames;
  final String? imdbId;

  MediaModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.mediaType,
    required this.voteAverage,
    this.voteCount = 0,
    required this.releaseDate,
    this.runtime = 0,
    required this.genreIds,
    this.genreNames = const [],
    this.imdbId,
  });

  String get posterUrl => posterPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get backdropUrl => backdropPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    final isMovie = json['media_type'] == 'movie' || json.containsKey('release_date');
    List<String> genres = [];
    if (json['genres'] != null) {
      genres = (json['genres'] as List).map((g) => g['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
    }
    return MediaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      originalTitle: json['original_title'] ?? json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      mediaType: json['media_type'] ?? (isMovie ? 'movie' : 'tv'),
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      genreNames: genres,
      imdbId: json['imdb_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'originalTitle': originalTitle,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'mediaType': mediaType,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'releaseDate': releaseDate,
      'runtime': runtime,
      'genreIds': genreIds,
      'genreNames': genreNames,
      'imdbId': imdbId,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      originalTitle: map['originalTitle'] ?? '',
      overview: map['overview'] ?? '',
      posterPath: map['posterPath'] ?? '',
      backdropPath: map['backdropPath'] ?? '',
      mediaType: map['mediaType'] ?? 'movie',
      voteAverage: (map['voteAverage'] ?? 0).toDouble(),
      voteCount: map['voteCount'] ?? 0,
      releaseDate: map['releaseDate'] ?? '',
      runtime: map['runtime'] ?? 0,
      genreIds: List<int>.from(map['genreIds'] ?? []),
      genreNames: List<String>.from(map['genreNames'] ?? []),
      imdbId: map['imdbId'] as String?,
    );
  }
}