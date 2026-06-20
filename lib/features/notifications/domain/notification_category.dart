enum NotificationCategory {
  newEpisode,
  newSeason,
  movieRelease,
  seriesRelease,
  dailyRecommendation,
  seriesUpdate;

  static NotificationCategory fromName(String value) {
    return NotificationCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationCategory.seriesUpdate,
    );
  }
}

extension NotificationCategoryX on NotificationCategory {
  String get displayName {
    switch (this) {
      case NotificationCategory.newEpisode:
        return 'Nuevo episodio';
      case NotificationCategory.newSeason:
        return 'Nueva temporada';
      case NotificationCategory.movieRelease:
        return 'Estreno de película';
      case NotificationCategory.seriesRelease:
        return 'Estreno de serie';
      case NotificationCategory.dailyRecommendation:
        return 'Recomendación diaria';
      case NotificationCategory.seriesUpdate:
        return 'Actualización de serie';
    }
  }

  String get shortName {
    switch (this) {
      case NotificationCategory.newEpisode:
        return 'Episodios';
      case NotificationCategory.newSeason:
        return 'Temporadas';
      case NotificationCategory.movieRelease:
        return 'Películas';
      case NotificationCategory.seriesRelease:
        return 'Series';
      case NotificationCategory.dailyRecommendation:
        return 'Recomendación';
      case NotificationCategory.seriesUpdate:
        return 'Actualizaciones';
    }
  }
}
