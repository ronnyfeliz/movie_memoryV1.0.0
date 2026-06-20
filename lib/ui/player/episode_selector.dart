import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SeasonInfo {
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterPath;

  const SeasonInfo({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.posterPath,
  });

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
    return SeasonInfo(
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? '',
      episodeCount: json['episode_count'] ?? 0,
      posterPath: json['poster_path'] as String?,
    );
  }
}

class EpisodeInfo {
  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final double voteAverage;

  const EpisodeInfo({
    required this.episodeNumber,
    required this.name,
    required this.overview,
    this.stillPath,
    this.voteAverage = 0.0,
  });

  factory EpisodeInfo.fromJson(Map<String, dynamic> json) {
    return EpisodeInfo(
      episodeNumber: json['episode_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
    );
  }
}

class EpisodeSelector extends StatefulWidget {
  final List<SeasonInfo> seasons;
  final int currentSeason;
  final int currentEpisode;
  final Future<List<EpisodeInfo>> Function(int seasonNumber) onFetchEpisodes;
  final void Function(int season, int episode) onSelectEpisode;

  const EpisodeSelector({
    super.key,
    required this.seasons,
    required this.currentSeason,
    required this.currentEpisode,
    required this.onFetchEpisodes,
    required this.onSelectEpisode,
  });

  @override
  State<EpisodeSelector> createState() => _EpisodeSelectorState();
}

class _EpisodeSelectorState extends State<EpisodeSelector> {
  late int _selectedSeason;
  List<EpisodeInfo> _episodes = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedSeason = widget.currentSeason;
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _loading = true);
    try {
      final episodes = await widget.onFetchEpisodes(_selectedSeason);
      if (mounted) setState(() => _episodes = episodes);
    } catch (_) {
      if (mounted) setState(() => _episodes = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final maxSelectorHeight = mediaQuery.size.height * 0.6;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSelectorHeight),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Temporadas y episodios',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (widget.seasons.length > 1)
                    DropdownButton<int>(
                      value: _selectedSeason,
                      dropdownColor: cs.surface,
                      style: TextStyle(color: cs.onSurface, fontSize: 14),
                      underline: const SizedBox(),
                      items: widget.seasons.map((s) {
                        return DropdownMenuItem(
                          value: s.seasonNumber,
                          child: Text(s.name.isNotEmpty ? s.name : 'Temporada ${s.seasonNumber}'),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedSeason = v);
                          _loadEpisodes();
                        }
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_episodes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No hay episodios disponibles',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _episodes.length,
                  itemBuilder: (_, i) {
                    final ep = _episodes[i];
                    final isCurrent = _selectedSeason == widget.currentSeason &&
                        ep.episodeNumber == widget.currentEpisode;

                    final hasStill = ep.stillPath != null && ep.stillPath!.isNotEmpty;

                    return InkWell(
                      onTap: () {
                        widget.onSelectEpisode(_selectedSeason, ep.episodeNumber);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: isCurrent ? cs.primary.withValues(alpha: 0.08) : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 90,
                                height: 60,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    hasStill
                                        ? CachedNetworkImage(
                                            imageUrl: 'https://image.tmdb.org/t/p/w200${ep.stillPath}',
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(color: cs.surfaceContainerHighest),
                                            errorWidget: (_, __, ___) => Container(
                                              color: cs.surfaceContainerHighest,
                                              child: const Icon(Icons.movie_outlined, size: 20),
                                            ),
                                          )
                                        : Container(
                                            color: cs.surfaceContainerHighest,
                                            child: const Icon(Icons.movie_outlined, size: 20),
                                          ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${ep.episodeNumber}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isCurrent)
                                      Container(
                                        color: cs.primary.withValues(alpha: 0.3),
                                        child: const Center(
                                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ep.name.isNotEmpty ? ep.name : 'Episodio ${ep.episodeNumber}',
                                    style: TextStyle(
                                      color: isCurrent ? cs.primary : cs.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (ep.overview.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      ep.overview,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
