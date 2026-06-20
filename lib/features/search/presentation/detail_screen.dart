import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../library/domain/library_item.dart';
import '../../library/domain/custom_list_model.dart';
import '../../library/data/library_provider.dart';
import '../../library/data/custom_list_provider.dart';
import '../domain/media_model.dart';
import '../../discover/data/discover_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'package:movie_memory/core/sound/sound_service.dart';
import 'package:movie_memory/core/sound/sound_provider.dart';
import 'package:movie_memory/ui/player/player_screen.dart';
import 'package:movie_memory/ui/player/episode_selector.dart';
import 'package:movie_memory/ui/player/comments_section.dart';
import 'package:movie_memory/services/progress_tracker.dart';
import '../../../ui/library/custom_list_privacy_badge.dart';
import '../../../core/notification/notification_provider.dart';
import '../../notifications/data/series_subscription_repository.dart';


class DetailScreen extends ConsumerStatefulWidget {
  final int tmdbId;
  final String mediaType;
  const DetailScreen({super.key, required this.tmdbId, required this.mediaType});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

String _translateDetail(String key, BuildContext context) {
  final lang = Localizations.localeOf(context).languageCode;
  final Map<String, Map<String, String>> dict = {
    'es': {
      'watch_series': 'Ver serie',
      'watch_movie': 'Ver película',
      'cannot_play_trailer': 'No se pudo reproducir el tráiler',
      'embedded_not_available': 'Error 153: reproducción embebida no disponible',
      'back': 'Volver',
      'open_youtube': 'Abrir en YouTube',
      'episodes': 'Episodios',
      'season': 'Temporada',
    },
    'en': {
      'watch_series': 'Watch Series',
      'watch_movie': 'Watch Movie',
      'cannot_play_trailer': 'Could not play trailer',
      'embedded_not_available': 'Error 153: embedded playback not available',
      'back': 'Back',
      'open_youtube': 'Open in YouTube',
      'episodes': 'Episodes',
      'season': 'Season',
    },
    'pt': {
      'watch_series': 'Ver série',
      'watch_movie': 'Ver filme',
      'cannot_play_trailer': 'Não foi possível reproduzir o trailer',
      'embedded_not_available': 'Erro 153: reprodução incorporada não disponível',
      'back': 'Voltar',
      'open_youtube': 'Abrir no YouTube',
      'episodes': 'Episódios',
      'season': 'Temporada',
    },
    'it': {
      'watch_series': 'Guarda la serie',
      'watch_movie': 'Guarda il film',
      'cannot_play_trailer': 'Impossibile riprodurre il trailer',
      'embedded_not_available': 'Errore 153: riproduzione incorporata non disponibile',
      'back': 'Indietro',
      'open_youtube': 'Apri su YouTube',
      'episodes': 'Episodi',
      'season': 'Stagione',
    },
    'fr': {
      'watch_series': 'Regarder la série',
      'watch_movie': 'Regarder le film',
      'cannot_play_trailer': 'Impossible de lire la bande-annonce',
      'embedded_not_available': 'Erreur 153 : lecture intégrée non disponible',
      'back': 'Retour',
      'open_youtube': 'Ouvrir sur YouTube',
      'episodes': 'Épisodes',
      'season': 'Saison',
    },
    'ru': {
      'watch_series': 'Смотреть сериал',
      'watch_movie': 'Смотреть фильм',
      'cannot_play_trailer': 'Не удалось воспроизвести трейлер',
      'embedded_not_available': 'Ошибка 153: встроенное воспроизведение недоступно',
      'back': 'Назад',
      'open_youtube': 'Открыть на YouTube',
      'episodes': 'Эпизоды',
      'season': 'Сезон',
    },
    'ko': {
      'watch_series': '시리즈 시청',
      'watch_movie': '영화 시청',
      'cannot_play_trailer': '예고편을 재생할 수 없습니다',
      'embedded_not_available': '오류 153: 임베디드 재생을 사용할 수 없습니다',
      'back': '돌아가기',
      'open_youtube': 'YouTube에서 열기',
      'episodes': '에피소드',
      'season': '시즌',
    },
    'ja': {
      'watch_series': 'シリーズを視聴',
      'watch_movie': '映画を視聴',
      'cannot_play_trailer': '予告編を再生できませんでした',
      'embedded_not_available': 'エラー 153: 埋め込み再生は利用できません',
      'back': '戻る',
      'open_youtube': 'YouTubeで開く',
      'episodes': 'エピソード',
      'season': 'シーズン',
    },
    'zh': {
      'watch_series': '观看电视剧',
      'watch_movie': '观看电影',
      'cannot_play_trailer': '无法播放预告片',
      'embedded_not_available': '错误 153：嵌入式播放不可用',
      'back': '返回',
      'open_youtube': '在 YouTube 中打开',
      'episodes': '剧集',
      'season': '季',
    }
  };
  return dict[lang]?[key] ?? dict['en']?[key] ?? key;
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  AsyncValue<MediaModel>? _detail;
  AsyncValue<bool>? _inLibrary;
  LibraryItem? _libraryItem;
  String? _trailerKey;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final api = ref.read(tmdbApiProvider);
    final repo = ref.read(libraryRepositoryProvider);

    setState(() {
      _detail = const AsyncValue.loading();
      _inLibrary = const AsyncValue.loading();
    });

    final detailResult = await AsyncValue.guard(() async {
      return widget.mediaType == 'tv'
          ? await api.getSeriesDetail(widget.tmdbId)
          : await api.getMovieDetail(widget.tmdbId);
    });

    if (!mounted) return;
    setState(() => _detail = detailResult);

    final inLibResult = await AsyncValue.guard(() async {
      final item = await repo.getItemByTmdbId(widget.tmdbId);
      _libraryItem = item;
      return item != null;
    });

    if (!mounted) return;
    setState(() => _inLibrary = inLibResult);

    final videosResult = await AsyncValue.guard(() async {
      final videos = widget.mediaType == 'tv'
          ? await api.getSeriesVideos(widget.tmdbId)
          : await api.getMovieVideos(widget.tmdbId);
      final trailer = videos.cast<Map<String, dynamic>>().firstWhere(
        (v) => v['site'] == 'YouTube' && (v['type'] == 'Trailer' || v['type'] == 'Teaser'),
        orElse: () => <String, dynamic>{},
      );
      return trailer['key'] as String?;
    });

    if (!mounted) return;
    setState(() => _trailerKey = videosResult.asData?.value);
  }

  Future<void> _addToLibrary(String status, {bool isFavorite = false}) async {
    final prefs = ref.read(soundPreferencesProvider);
    if (status == LibraryStatus.watched) {
      await SoundService.playConfirm(prefs);
    } else {
      await SoundService.playAdd(prefs);
    }
    final model = _detail?.asData?.value;
    if (model == null) return;
    final repo = ref.read(libraryRepositoryProvider);

    final item = LibraryItem(
      id: '',
      tmdbId: widget.tmdbId,
      title: model.title,
      posterPath: model.posterPath,
      mediaType: widget.mediaType,
      status: status,
      category: widget.mediaType == 'movie'
          ? LibraryCategory.movie
          : widget.mediaType == 'tv'
              ? LibraryCategory.series
              : widget.mediaType,
      isFavorite: isFavorite,
      year: model.year,
      addedAt: DateTime.now(),
      watchedAt: status == LibraryStatus.watched ? DateTime.now() : null,
      genres: model.genreNames,
    );

    await repo.addItem(item);
    if (!mounted) return;
    final updated = await repo.getItemByTmdbId(widget.tmdbId);
    setState(() {
      _libraryItem = updated;
      _inLibrary = const AsyncValue.data(true);
    });
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      final msg = isFavorite ? l10n.addedToFavorites
          : status == LibraryStatus.watchLater ? l10n.addedToWatchLater
          : status == LibraryStatus.watched ? l10n.markedAsWatched
          : l10n.addedToLibrary;
      final bgColor = isFavorite ? Colors.green
          : status == LibraryStatus.watched ? Colors.green
          : Colors.blue;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: bgColor,
        content: Text(msg),
      ));
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playAdd(prefs);
    if (_libraryItem == null) {
      await _addToLibrary(LibraryStatus.watchLater, isFavorite: true);
      return;
    }
    final repo = ref.read(libraryRepositoryProvider);
    await repo.updateItem(_libraryItem!.copyWith(isFavorite: !_libraryItem!.isFavorite));
    final updated = await repo.getItemByTmdbId(widget.tmdbId);
    setState(() => _libraryItem = updated);
  }

  Future<void> _updateStatus(String status) async {
    final prefs = ref.read(soundPreferencesProvider);
    if (status == LibraryStatus.watched) {
      await SoundService.playConfirm(prefs);
    } else {
      await SoundService.playClick(prefs);
    }
    if (_libraryItem == null) return;
    final repo = ref.read(libraryRepositoryProvider);
    await repo.updateItem(_libraryItem!.copyWith(
      status: status,
      watchedAt: status == LibraryStatus.watched ? DateTime.now() : null,
    ));
    final updated = await repo.getItemByTmdbId(widget.tmdbId);
    setState(() => _libraryItem = updated);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: status == LibraryStatus.watched ? Colors.green : Colors.blue,
        content: Text(status == LibraryStatus.watched ? l10n.markedAsWatched : l10n.movedToWatchLater),
      ));
    }
  }

  Future<void> _addToList() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(libraryRepositoryProvider);

    LibraryItem? libItem = _libraryItem;
    if (libItem == null) {
      final model = _detail?.asData?.value;
      if (model == null) return;
      final item = LibraryItem(
        id: '',
        tmdbId: widget.tmdbId,
        title: model.title,
        posterPath: model.posterPath,
        mediaType: widget.mediaType,
        status: LibraryStatus.listed,
        category: widget.mediaType == 'movie'
            ? LibraryCategory.movie
            : widget.mediaType == 'tv'
                ? LibraryCategory.series
                : widget.mediaType,
        year: model.year,
        addedAt: DateTime.now(),
        genres: model.genreNames,
      );
      await repo.addItem(item);
      if (!mounted) return;
      final updated = await repo.getItemByTmdbId(widget.tmdbId);
      setState(() {
        _libraryItem = updated;
        _inLibrary = const AsyncValue.data(true);
      });
      libItem = _libraryItem;
      if (libItem == null) return;
    }

    final allLists = ref.read(customListsStreamProvider).valueOrNull ?? [];
    final availableLists = allLists.where((l) => !l.itemIds.contains(libItem!.id)).toList();

    if (allLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orange,
        content: Text(l10n.addToList),
      ));
      return;
    }

    if (availableLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orange,
        content: Text(l10n.noItemsInList),
      ));
      return;
    }

    final selected = await showModalBottomSheet<CustomListModel>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.selectList,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            ),
            Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: availableLists.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Icon(Icons.list, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          availableLists[i].name,
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomListPrivacyBadge(isPublic: availableLists[i].isPublic, small: true),
                    ],
                  ),
                  subtitle: availableLists[i].description.isNotEmpty
                      ? Text(availableLists[i].description, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))
                      : null,
                  trailing: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                  onTap: () => Navigator.pop(ctx, availableLists[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      await ref.read(customListRepositoryProvider).addItemToList(selected.id, libItem.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('${l10n.addedToList}: "${selected.name}"'),
        ));
      }
    }
  }

  Future<void> _removeFromLibrary() async {
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playRemove(prefs);
    if (_libraryItem == null) return;
    final repo = ref.read(libraryRepositoryProvider);
    await repo.removeItem(_libraryItem!.id);
    setState(() {
      _libraryItem = null;
      _inLibrary = const AsyncValue.data(false);
    });
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(l10n.removedFromLibrary),
      ));
    }
  }

  Future<void> _shareItem(MediaModel model) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    final type = widget.mediaType == 'tv' ? l10n.typeSeries : l10n.typeMovie;
    final tmdbUrl = 'https://www.themoviedb.org/${widget.mediaType}/${widget.tmdbId}';
    final text = '${l10n.shareMovie(model.title, type)}\n\n'
        '${l10n.shareMovieDescription(model.overview.isNotEmpty ? model.overview : l10n.noSynopsis)}\n\n$tmdbUrl';
    await Share.share(text);
  }

  Future<void> _playEmbed({int? season, int? episode}) async {
    final model = _detail?.asData?.value;
    if (model == null) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          tmdbId: widget.tmdbId,
          mediaType: widget.mediaType,
          title: model.title,
          posterPath: model.posterPath,
          season: season ?? (widget.mediaType == 'tv' ? 1 : null),
          episode: episode ?? (widget.mediaType == 'tv' ? 1 : null),
          onFetchSeasons: widget.mediaType == 'tv'
              ? () => _fetchSeasons()
              : null,
          onFetchEpisodes: widget.mediaType == 'tv'
              ? (s) => _fetchEpisodes(s)
              : null,
        ),
      ),
    );
  }

  Future<List<SeasonInfo>> _fetchSeasons() async {
    final api = ref.read(tmdbApiProvider);
    try {
      final data = await api.getSeriesSeasons(widget.tmdbId);
      return data.map((j) => SeasonInfo.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<EpisodeInfo>> _fetchEpisodes(int seasonNumber) async {
    final api = ref.read(tmdbApiProvider);
    try {
      final data = await api.getSeasonDetails(widget.tmdbId, seasonNumber);
      final episodes = data['episodes'] as List<dynamic>? ?? [];
      return episodes
          .cast<Map<String, dynamic>>()
          .map((j) => EpisodeInfo.fromJson(j))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final inLibrary = _inLibrary;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: detail?.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: cs.error, size: 48),
                const SizedBox(height: 16),
                Text('${AppLocalizations.of(context)!.errorLoading}: $e', textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
              ],
            ),
          ),
        ),
        data: (model) => CustomScrollView(
          slivers: [
            _SliverAppBar(
              model: model,
              trailerKey: _trailerKey,
              isFavorite: _libraryItem?.isFavorite ?? false,
              onToggleFavorite: _toggleFavorite,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleSection(model: model),
                    const SizedBox(height: 16),
                    if (model.genreNames.isNotEmpty) ...[
                      Wrap(
                        spacing: 8, runSpacing: 4,
                        children: model.genreNames.map((g) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(g, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionTitle(AppLocalizations.of(context)!.synopsis),
                    const SizedBox(height: 8),
                    Text(
                      model.overview.isNotEmpty ? model.overview : AppLocalizations.of(context)!.noSynopsis,
                      style: TextStyle(
                        color: model.overview.isNotEmpty ? cs.onSurface : cs.onSurfaceVariant,
                        fontSize: 14, height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle(inLibrary?.valueOrNull == true ? AppLocalizations.of(context)!.inYourLibrary : AppLocalizations.of(context)!.actions),
                        IconButton(
                          icon: Icon(Icons.share, color: cs.onSurfaceVariant),
                          tooltip: AppLocalizations.of(context)!.share,
                          onPressed: () => _shareItem(model),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    inLibrary?.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text(AppLocalizations.of(context)!.error, style: TextStyle(color: cs.error)),
                      data: (isIn) => isIn && _libraryItem != null
                          ? _LibraryActions(
                              item: _libraryItem!,
                              onToggleFavorite: _toggleFavorite,
                              onUpdateStatus: _updateStatus,
                              onRemove: _removeFromLibrary,
                              onAddToList: () async {
                                final prefs = ref.read(soundPreferencesProvider);
                                await SoundService.playClick(prefs);
                                await _addToList();
                              },
                            )
                          : _AddActions(
                              onWatchLater: () => _addToLibrary(LibraryStatus.watchLater),
                              onWatched: () => _addToLibrary(LibraryStatus.watched),
                              onAddFavorite: () => _addToLibrary(LibraryStatus.favorite, isFavorite: true),
                              onAddToList: () async {
                                final prefs = ref.read(soundPreferencesProvider);
                                await SoundService.playAdd(prefs);
                                await _addToList();
                              },
                            ),
                    ) ?? const SizedBox.shrink(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _playEmbed,
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: Text(
                          widget.mediaType == 'tv' 
                              ? _translateDetail('watch_series', context)
                              : _translateDetail('watch_movie', context),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.mediaType == 'tv')
                      _EpisodesSection(
                        tmdbId: widget.tmdbId,
                        onPlayEpisode: (s, e) => _playEmbed(season: s, episode: e),
                        fetchSeasons: _fetchSeasons,
                        fetchEpisodes: _fetchEpisodes,
                      ),
                    CommentsSection(tmdbId: widget.tmdbId, mediaType: widget.mediaType),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ) ?? const SizedBox.shrink(),
    );
  }
}

class _SliverAppBar extends ConsumerStatefulWidget {
  final MediaModel model;
  final String? trailerKey;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  const _SliverAppBar({
    required this.model,
    required this.trailerKey,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  ConsumerState<_SliverAppBar> createState() => _SliverAppBarState();
}

class _SliverAppBarState extends ConsumerState<_SliverAppBar> {
  bool? _isSubscribed;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final subscribed = await ref.read(seriesSubscriptionRepositoryProvider).isSubscribed(uid, widget.model.id);
    if (mounted) setState(() => _isSubscribed = subscribed);
  }

  Future<void> _toggleSubscription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    await ref.read(seriesSubscriptionRepositoryProvider).toggleSubscription(
      uid,
      widget.model.id,
      widget.model.title,
      widget.model.posterPath,
      widget.model.mediaType,
    );
    final subscribed = await ref.read(seriesSubscriptionRepositoryProvider).isSubscribed(uid, widget.model.id);
    if (mounted) setState(() => _isSubscribed = subscribed);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(subscribed ? 'Notificaciones activadas para esta serie' : 'Notificaciones desactivadas'),
      ));
    }
  }

  Future<void> _playTrailer(BuildContext context, WidgetRef ref) async {
    final key = widget.trailerKey;
    if (key == null) return;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TrailerScreen(videoKey: key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTv = widget.model.mediaType == 'tv';
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: cs.surface,
      actions: [
        if (isTv) ...[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _toggleSubscription,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                ),
                child: Icon(
                  _isSubscribed == true ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  color: _isSubscribed == true ? cs.primary : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: widget.onToggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
              ),
              child: Icon(
                widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: widget.isFavorite ? cs.primary : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.model.backdropPath.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.model.backdropUrl,
                fit: BoxFit.cover,
              )
            else
              Container(color: cs.surfaceContainerHighest),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      cs.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16, bottom: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          width: 100, height: 150,
                          child: widget.model.posterPath.isNotEmpty
                              ? CachedNetworkImage(imageUrl: widget.model.posterUrl, fit: BoxFit.cover)
                              : Container(color: cs.surfaceContainerHighest, child: Icon(Icons.movie_rounded, color: cs.onSurfaceVariant)),
                        ),
                      ),
                    ],
                  ),
                  if (widget.trailerKey != null) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _playTrailer(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
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
  }
}

class _TitleSection extends StatelessWidget {
  final MediaModel model;
  const _TitleSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(model.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (model.year.isNotEmpty) ...[
              Text(model.year, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
              const SizedBox(width: 12),
              Container(width: 1, height: 14, color: cs.outlineVariant),
              const SizedBox(width: 12),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                model.mediaType == 'movie' ? AppLocalizations.of(context)!.movie : AppLocalizations.of(context)!.series,
                style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(model.voteAverage.toStringAsFixed(1), style: TextStyle(color: cs.onSurface, fontSize: 14)),
            Text(' (${model.voteCount})', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ],
        ),
        if (model.runtime > 0) ...[
          const SizedBox(height: 4),
          Text('${model.runtime} ${AppLocalizations.of(context)!.minutesLabel}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface));
  }
}

class _AddActions extends StatelessWidget {
  final VoidCallback onWatchLater;
  final VoidCallback onWatched;
  final VoidCallback onAddFavorite;
  final VoidCallback onAddToList;
  const _AddActions({
    required this.onWatchLater,
    required this.onWatched,
    required this.onAddFavorite,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.watch_later_outlined,
                label: l10n.addToWatchLater,
                color: cs.primary,
                onTap: onWatchLater,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.check_circle_outline,
                label: l10n.markAsWatched,
                color: Colors.green,
                onTap: onWatched,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.favorite_border,
                label: l10n.addToFavorites,
                color: Colors.amber,
                onTap: onAddFavorite,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.playlist_add,
                label: l10n.addToList,
                color: cs.primary,
                onTap: onAddToList,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LibraryActions extends StatelessWidget {
  final LibraryItem item;
  final VoidCallback onToggleFavorite;
  final Function(String) onUpdateStatus;
  final VoidCallback onRemove;
  final VoidCallback onAddToList;
  const _LibraryActions({
    required this.item,
    required this.onToggleFavorite,
    required this.onUpdateStatus,
    required this.onRemove,
    required this.onAddToList,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: item.status == LibraryStatus.watched
                ? Colors.green.withValues(alpha: 0.15)
                : item.status == LibraryStatus.favorite
                    ? Colors.amber.withValues(alpha: 0.15)
                    : cs.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.status == LibraryStatus.watched ? Icons.check_circle
                    : item.status == LibraryStatus.favorite ? Icons.favorite
                    : Icons.watch_later,
                color: item.status == LibraryStatus.watched ? Colors.green
                    : item.status == LibraryStatus.favorite ? Colors.amber
                    : cs.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                item.status == LibraryStatus.watched ? l10n.markAsWatchedShort
                    : item.status == LibraryStatus.favorite ? l10n.favoriteShort
                    : l10n.addToWatchLater,
                style: TextStyle(
                  color: item.status == LibraryStatus.watched ? Colors.green
                      : item.status == LibraryStatus.favorite ? Colors.amber
                      : cs.primary,
                  fontSize: 13,
                ),
              ),
              if (item.isFavorite && item.status != LibraryStatus.favorite) ...[
                const SizedBox(width: 8),
                const Icon(Icons.favorite, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(l10n.favoriteShort, style: const TextStyle(color: Colors.amber, fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (item.status != LibraryStatus.watched)
          _ActionButton(icon: Icons.check_circle_outline, label: l10n.markAsWatchedAction,
              color: Colors.green, onTap: () => onUpdateStatus(LibraryStatus.watched)),
        if (item.status != LibraryStatus.watchLater)
          _ActionButton(icon: Icons.watch_later_outlined, label: l10n.moveToWatchLater,
              color: cs.primary, onTap: () => onUpdateStatus(LibraryStatus.watchLater)),
        const SizedBox(height: 8),
        _ActionButton(
          icon: item.isFavorite ? Icons.favorite : Icons.favorite_border,
          label: item.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
          color: Colors.amber,
          onTap: onToggleFavorite,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.playlist_add,
          label: l10n.addToList,
          color: cs.primary,
          onTap: onAddToList,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.delete_outline,
          label: l10n.removeFromLibrary,
          color: Colors.red,
          onTap: onRemove,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: c, size: 20),
        label: Text(label, style: TextStyle(color: c, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: c.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _TrailerScreen extends ConsumerStatefulWidget {
  final String videoKey;
  const _TrailerScreen({required this.videoKey});

  @override
  ConsumerState<_TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends ConsumerState<_TrailerScreen> {
  bool _hasError = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.6099.144 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          if (mounted) setState(() => _hasError = true);
        },
        onPageFinished: (url) {
          if (mounted && _hasError) return;
        },
      ))
      ..loadRequest(Uri.parse(
        'https://www.youtube-nocookie.com/embed/${widget.videoKey}?'
        'autoplay=1&mute=1&playsinline=1',
      ));
  }

  @override
  void dispose() {
    _controller.clearCache();
    _controller.loadRequest(Uri.parse('about:blank'));
    super.dispose();
  }

  Future<void> _openInYouTubeApp() async {
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    final url = 'https://www.youtube.com/watch?v=${widget.videoKey}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: cs.onSurface.withValues(alpha: 0.7), size: 48),
              const SizedBox(height: 16),
              Text(_translateDetail('cannot_play_trailer', context), style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text(_translateDetail('embedded_not_available', context), style: const TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final prefs = ref.read(soundPreferencesProvider);
                  await SoundService.playClick(prefs);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                label: Text(_translateDetail('back', context), style: const TextStyle(color: Colors.white70)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openInYouTubeApp,
                icon: const Icon(Icons.open_in_new, color: Color(0xFFFF0000)),
                label: Text(_translateDetail('open_youtube', context), style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.withValues(alpha: 0.24))),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final prefs = ref.read(soundPreferencesProvider);
            await SoundService.playClick(prefs);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Episodes Section (TV shows only)
// ─────────────────────────────────────────────────────────────────────────────

class _EpisodesSection extends StatefulWidget {
  final int tmdbId;
  final void Function(int season, int episode) onPlayEpisode;
  final Future<List<SeasonInfo>> Function() fetchSeasons;
  final Future<List<EpisodeInfo>> Function(int season) fetchEpisodes;

  const _EpisodesSection({
    required this.tmdbId,
    required this.onPlayEpisode,
    required this.fetchSeasons,
    required this.fetchEpisodes,
  });

  @override
  State<_EpisodesSection> createState() => _EpisodesSectionState();
}

class _EpisodesSectionState extends State<_EpisodesSection> {
  List<SeasonInfo> _seasons = [];
  List<EpisodeInfo> _episodes = [];
  int _selectedSeason = 1;
  bool _loadingSeasons = true;
  bool _loadingEpisodes = false;
  final Map<String, double> _progressCache = {};

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    try {
      final seasons = await widget.fetchSeasons();
      if (!mounted) return;
      setState(() {
        _seasons = seasons;
        _loadingSeasons = false;
        if (seasons.isNotEmpty) {
          _selectedSeason = seasons.first.seasonNumber;
        }
      });
      await _loadEpisodes(_selectedSeason);
    } catch (_) {
      if (mounted) setState(() => _loadingSeasons = false);
    }
  }

  Future<void> _loadEpisodes(int season) async {
    setState(() => _loadingEpisodes = true);
    try {
      final episodes = await widget.fetchEpisodes(season);
      if (!mounted) return;
      final Map<String, double> progress = {};
      for (final ep in episodes) {
        final p = await ProgressTracker.getProgress(
          widget.tmdbId,
          season: season,
          episode: ep.episodeNumber,
        );
        progress['${season}_${ep.episodeNumber}'] = p;
      }
      setState(() {
        _episodes = episodes;
        _progressCache.addAll(progress);
        _loadingEpisodes = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingEpisodes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loadingSeasons) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_seasons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _translateDetail('episodes', context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            if (_seasons.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: DropdownButton<int>(
                  value: _selectedSeason,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  items: _seasons.map((s) => DropdownMenuItem(
                    value: s.seasonNumber,
                    child: Text(
                      '${_translateDetail('season', context)} ${s.seasonNumber}',
                      style: TextStyle(fontSize: 13, color: cs.onSurface),
                    ),
                  )).toList(),
                  onChanged: (v) {
                    if (v == null || v == _selectedSeason) return;
                    setState(() => _selectedSeason = v);
                    _loadEpisodes(v);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingEpisodes)
          const Center(child: CircularProgressIndicator())
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _episodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final ep = _episodes[i];
              final pKey = '${_selectedSeason}_${ep.episodeNumber}';
              final p = _progressCache[pKey] ?? 0.0;
              return _EpisodeCard(
                episode: ep,
                season: _selectedSeason,
                progress: p,
                onTap: () => widget.onPlayEpisode(_selectedSeason, ep.episodeNumber),
              );
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final EpisodeInfo episode;
  final int season;
  final double progress;
  final VoidCallback onTap;

  const _EpisodeCard({
    required this.episode,
    required this.season,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasProgress = progress > 0.01;
    final isWatched = progress >= 0.95;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 110,
                      height: 65,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          episode.stillPath != null
                              ? CachedNetworkImage(
                                  imageUrl: 'https://image.tmdb.org/t/p/w300${episode.stillPath}',
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(Icons.tv, color: cs.onSurfaceVariant, size: 28),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: cs.surfaceContainerHighest,
                                    child: Icon(Icons.tv, color: cs.onSurfaceVariant, size: 28),
                                  ),
                                )
                              : Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(Icons.tv, color: cs.onSurfaceVariant, size: 28),
                                ),
                          Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isWatched ? Icons.replay_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          if (isWatched)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.markAsWatchedShort,
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E${episode.episodeNumber}. ${episode.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: cs.onSurface,
                          ),
                        ),
                        if (episode.overview.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            episode.overview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasProgress && !isWatched)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
