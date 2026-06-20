class EpisodeNavigator {
  const EpisodeNavigator._();

  static ({int season, int episode})? nextEpisode({
    required int currentSeason,
    required int currentEpisode,
    required int maxEpisodesInSeason,
  }) {
    if (currentEpisode < maxEpisodesInSeason) {
      return (season: currentSeason, episode: currentEpisode + 1);
    }
    return null;
  }

  static ({int season, int episode})? nextSeason({
    required int currentSeason,
    required int currentEpisode,
    required int maxEpisodesInSeason,
    int? maxSeasons,
  }) {
    if (currentEpisode >= maxEpisodesInSeason) {
      final nextSeason = currentSeason + 1;
      if (maxSeasons == null || nextSeason <= maxSeasons) {
        return (season: nextSeason, episode: 1);
      }
    }
    return null;
  }
}
