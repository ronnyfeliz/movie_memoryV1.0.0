import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class LibraryItem {
  final String id;
  final int tmdbId;
  final String title;
  final String posterPath;
  final String mediaType;
  final String status;
  final String category;
  final bool isFavorite;
  final String year;
  final double? rating;
  final String? notes;
  final DateTime addedAt;
  final DateTime? watchedAt;
  final List<String> genres;

  LibraryItem({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.posterPath,
    required this.mediaType,
    required this.status,
    this.category = LibraryCategory.movie,
    this.isFavorite = false,
    this.year = '',
    this.rating,
    this.notes,
    required this.addedAt,
    this.watchedAt,
    this.genres = const [],
  });

  String get posterUrl => posterPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  Map<String, dynamic> toMap() {
    return {
      'tmdbId': tmdbId,
      'title': title,
      'posterPath': posterPath,
      'mediaType': mediaType,
      'status': status,
      'category': category,
      'isFavorite': isFavorite,
      'year': year,
      'rating': rating,
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
      'watchedAt': watchedAt?.toIso8601String(),
      'genres': genres,
    };
  }

  factory LibraryItem.fromMap(String id, Map<String, dynamic> map) {
    return LibraryItem(
      id: id,
      tmdbId: map['tmdbId'] ?? 0,
      title: map['title'] ?? '',
      posterPath: map['posterPath'] ?? '',
      mediaType: map['mediaType'] ?? 'movie',
      status: map['status'] ?? 'watch_later',
      category: map['category'] ?? LibraryCategory.movie,
      isFavorite: map['isFavorite'] ?? false,
      year: map['year'] ?? '',
      rating: map['rating']?.toDouble(),
      notes: map['notes'],
      addedAt: DateTime.parse(map['addedAt'] ?? DateTime.now().toIso8601String()),
      watchedAt: map['watchedAt'] != null ? DateTime.parse(map['watchedAt']) : null,
      genres: List<String>.from(map['genres'] ?? []),
    );
  }

  LibraryItem copyWith({
    String? status,
    String? category,
    bool? isFavorite,
    String? year,
    double? rating,
    String? notes,
    DateTime? watchedAt,
  }) {
    return LibraryItem(
      id: id,
      tmdbId: tmdbId,
      title: title,
      posterPath: posterPath,
      mediaType: mediaType,
      status: status ?? this.status,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      addedAt: addedAt,
      watchedAt: watchedAt ?? this.watchedAt,
      genres: genres,
    );
  }
}

class LibraryStatus {
  static const watchLater = 'watch_later';
  static const watching = 'watching';
  static const watched = 'watched';
  static const favorite = 'favorite';
  static const listed = 'listed';
}

class LibraryCategory {
  static const movie = 'movie';
  static const series = 'series';
  static const anime = 'anime';
  static const cartoon = 'cartoon';
  static const documentary = 'documentary';
  static const concert = 'concert';
  static const other = 'other';

  static String label(String category) {
    switch (category) {
      case movie: return 'Película';
      case series: return 'Serie';
      case anime: return 'Anime';
      case cartoon: return 'Caricatura';
      case documentary: return 'Documental';
      case concert: return 'Concierto';
      default: return 'Otro';
    }
  }

  static String localizedLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case movie: return l10n.movie;
      case series: return l10n.series;
      case anime: return l10n.anime;
      case cartoon: return l10n.cartoon;
      case documentary: return l10n.documentary;
      case concert: return l10n.concert;
      default: return l10n.other;
    }
  }

  static IconData icon(String category) {
    switch (category) {
      case movie: return Icons.movie_outlined;
      case series: return Icons.tv_outlined;
      case anime: return Icons.animation_outlined;
      case cartoon: return Icons.face_outlined;
      case documentary: return Icons.document_scanner_outlined;
      case concert: return Icons.music_note_outlined;
      default: return Icons.category_outlined;
    }
  }

  static final List<String> all = [
    movie, series, anime, cartoon, documentary, concert, other
  ];
}