import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'discover_provider.dart';
import '../../search/domain/media_model.dart';

final dailyRecommendationProvider = FutureProvider<MediaModel?>((ref) async {
  final todayStr = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd

  try {
    final doc = await FirebaseFirestore.instance
        .collection('dailyRecommendations')
        .doc(todayStr)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      return MediaModel(
        id: data['tmdbId'] ?? 0,
        title: data['title'] ?? data['name'] ?? '',
        originalTitle: data['originalTitle'] ?? data['original_title'] ?? data['original_name'] ?? data['title'] ?? '',
        overview: data['overview'] ?? '',
        posterPath: data['posterPath'] ?? '',
        backdropPath: data['backdropPath'] ?? '',
        mediaType: data['mediaType'] ?? 'movie',
        voteAverage: (data['voteAverage'] ?? 0.0).toDouble(),
        voteCount: data['voteCount'] ?? 0,
        releaseDate: data['releaseDate'] ?? '',
        genreIds: List<int>.from(data['genreIds'] ?? []),
      );
    }
  } catch (e) {
    // Silently ignore firestore error and fallback to trending
  }

  // Fallback a trending
  final trending = await ref.read(trendingProvider.future);
  if (trending.isEmpty) return null;

  final now = DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final rand = Random(seed);
  return trending[rand.nextInt(trending.length)];
});
