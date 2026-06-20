import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_controller.dart';
import 'server_selector.dart';
import 'embed_url_builder.dart';
import 'language_manager.dart';
import '../../services/watch_history_service.dart';
import '../../services/progress_tracker.dart';
import '../../services/episode_navigator.dart';
import '../network/tmdb_api.dart';

class PlaybackManager {
  final PlayerController controller = PlayerController();

  final int tmdbId;
  final String mediaType;
  final String? title;
  final String? posterPath;
  int? season;
  int? episode;

  PlayerLanguage _currentLang = PlayerLanguage.es;
  String _resolvedAudioLang = 'es';
  String _resolvedSubtitleLang = '';
  String _currentServer = '';
  int _failCount = 0;
  bool _hasFallenBackToOriginal = false;
  bool _autoNext = true;
  bool _subsEnabled = true;
  int? _selectedSubtitleTrack;
  int? _selectedQuality;
  Timer? _loadingTimer;
  Timer? _progressTimer;
  bool _isDisposed = false;
  double? _lastKnownProgress;
  String? _imdbId;
  int maxEpisodesInSeason = 24; // valor por defecto, se actualiza con datos reales

  static const _maxServerAttempts = 5;
  static const _loadingTimeout = Duration(seconds: 10);
  static const _progressInterval = Duration(seconds: 5);

  // ─── FIX: ValueNotifier que el WebView escucha para recargar ─────────────
  // En lugar de depender solo del estado del controller,
  // el WebView observa este notifier y llama loadRequest() cada vez que cambia.
  final ValueNotifier<String> urlNotifier = ValueNotifier('');

  PlaybackManager({
    required this.tmdbId,
    required this.mediaType,
    this.season,
    this.episode,
    this.title,
    this.posterPath,
  });

  String get currentServer => _currentServer;
  PlayerLanguage get currentLang => _currentLang;
  bool get autoNext => _autoNext;
  bool get subsEnabled => _subsEnabled;
  int? get selectedSubtitleTrack => _selectedSubtitleTrack;
  int? get selectedQuality => _selectedQuality;
  int get failCount => _failCount;

  String get urlForCurrentState => _buildUrl();

  Future<void> _init() async {
    try {
      _hasFallenBackToOriginal = false;

      final resolved = await LanguageManager.resolvePlaybackLanguages();
      _resolvedAudioLang = resolved['audio'] ?? 'es';
      _resolvedSubtitleLang = resolved['subtitle'] ?? '';

      if (_currentServer.isEmpty) {
        _currentLang = PlayerLanguage.fromCode(_resolvedAudioLang.toUpperCase());
        _currentServer = await ServerSelector.getBestServerForLanguage(
          tmdbId,
          _currentLang.code,
        );
      }
    } catch (e) {
      debugPrint('[PlaybackManager] _init error: $e');
      _resolvedAudioLang = 'es';
      _resolvedSubtitleLang = '';
      if (_currentServer.isEmpty) {
        _currentServer = ServerSelector.servers.first.name;
      }
    }
  }

  Future<void> init() async {
    try {
      if (mediaType == 'movie') {
        final detail = await TmdbApi().getMovieDetail(tmdbId);
        _imdbId = detail.imdbId;
      } else {
        final detail = await TmdbApi().getSeriesDetail(tmdbId);
        _imdbId = detail.imdbId;
      }
      debugPrint('[PlaybackManager] Retrieved IMDb ID: $_imdbId');
    } catch (e) {
      debugPrint('[PlaybackManager] Error fetching IMDb ID: $e');
    }
    await loadAutoNext();
    await _init();
    _startProgressTimer();
  }

  String _buildUrl() {
    final server = _currentServer.isNotEmpty ? _currentServer : null;
    return EmbedUrlBuilder.buildUrl(
      mediaType, tmdbId,
      server: server,
      audioLang: _resolvedAudioLang,
      subtitleLang: _resolvedSubtitleLang,
      season: season,
      episode: episode,
    );
  }

  String buildUrlFor(String server, PlayerLanguage lang) {
    return EmbedUrlBuilder.buildUrl(
      mediaType, tmdbId,
      server: server,
      audioLang: lang == PlayerLanguage.original ? 'original' : lang.code.toLowerCase(),
      subtitleLang: _resolvedSubtitleLang,
      season: season,
      episode: episode,
    );
  }

  // ─── FIX: load() ahora actualiza urlNotifier ANTES de cambiar el estado ──
  void load() {
    if (_isDisposed) return;
    final newUrl = _buildUrl();
    debugPrint('[PlaybackManager] load() → $newUrl');
    urlNotifier.value = newUrl;          // ← WebView reacciona aquí
    controller.onLoadStart(server: _currentServer);
    _startLoadingTimer();
  }

  void onWebViewReady() {
    if (_isDisposed) return;
    _cancelLoadingTimer();
    controller.onLoadComplete();
    ServerSelector.markSuccess(tmdbId, _currentServer, langCode: _currentLang.code);
  }

  void onPageLoadError(String description) {
    if (_isDisposed) return;
    _cancelLoadingTimer();
    _failCount++;
    _tryNextServer();
  }

  void onTimeoutHit() {
    if (_isDisposed) return;
    _failCount++;
    _tryNextServer();
  }

  Future<void> _tryNextServer() async {
    try {
      if (_failCount >= _maxServerAttempts) {
        if (_currentLang != PlayerLanguage.original && !_hasFallenBackToOriginal) {
          _hasFallenBackToOriginal = true;
          _currentLang = PlayerLanguage.original;
          _resolvedAudioLang = 'original';
          _failCount = 0;
          await ServerSelector.resetFailCache(tmdbId);
          _currentServer = await ServerSelector.getBestServerForLanguage(tmdbId, _currentLang.code);
          controller.onSwitchingServer(_currentServer);
          await Future.delayed(const Duration(milliseconds: 800));
          if (_isDisposed) return;
          load();
          return;
        }
        controller.onError('No available servers after $_maxServerAttempts attempts');
        return;
      }

      await ServerSelector.recordFailure(tmdbId, _currentServer);
      final nextServer = await ServerSelector.switchServer(
        tmdbId, _currentServer, langCode: _currentLang.code,
      );
      _currentServer = nextServer;
      controller.onSwitchingServer(_currentServer);
      await Future.delayed(const Duration(milliseconds: 800));
      if (_isDisposed) return;
      load();
    } catch (e) {
      debugPrint('[PlaybackManager] _tryNextServer error: $e');
      if (!_isDisposed) {
        controller.onError('Error switching server: $e');
      }
    }
  }

  void _startLoadingTimer() {
    _cancelLoadingTimer();
    _loadingTimer = Timer(_loadingTimeout, () {
      if (!_isDisposed && controller.state == PlayState.loading) onTimeoutHit();
    });
  }

  void _cancelLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(_progressInterval, (_) {
      if (!_isDisposed) _savePeriodicProgress();
    });
  }

  void _savePeriodicProgress() {
    if (_isDisposed) return;
    if (controller.state == PlayState.loaded) _saveProgress(null);
  }

  // ─── FIX: changeLanguage() ahora llama a load() que actualiza la URL ─────
  Future<void> changeLanguage(PlayerLanguage lang) async {
    if (_isDisposed) return;
    try {
      _currentLang = lang;
      _failCount = 0;
      _hasFallenBackToOriginal = false;

      await LanguageManager.setLang(lang);
      await ServerSelector.resetFailCache(tmdbId);
      await ServerSelector.clearServerPreference(tmdbId);

      _resolvedAudioLang = lang == PlayerLanguage.original ? 'original' : lang.code.toLowerCase();

      _currentServer = await ServerSelector.getBestServerForLanguage(
        tmdbId, lang.code,
      );
      debugPrint('[Player] changeLanguage: server=$_currentServer');

      load();
    } catch (e) {
      debugPrint('[PlaybackManager] changeLanguage error: $e');
      _resolvedAudioLang = 'es';
      if (_currentServer.isEmpty) {
        _currentServer = ServerSelector.servers.first.name;
      }
      load();
    }
  }

  // changeLanguageWithFallback simplificado sin await 10s bloqueante
  Future<void> changeLanguageWithFallback(PlayerLanguage lang) async {
    if (_isDisposed) return;
    // Intenta directamente — el mecanismo de _tryNextServer se encarga del fallback
    await changeLanguage(lang);
  }

  Future<void> changeServerManual(String serverName) async {
    if (_isDisposed) return;
    _currentServer = serverName;
    _failCount = 0;
    _hasFallenBackToOriginal = false;
    controller.resetForRetry();
    if (!_isDisposed) load();
  }

  Future<void> retry() async {
    if (_isDisposed) return;
    _failCount = 0;
    _hasFallenBackToOriginal = false;
    controller.resetForRetry();
    if (!_isDisposed) load();
  }

  void reportPlaybackPosition(double currentTime, double duration) {
    if (_isDisposed) return;
    final pct = duration > 0 ? (currentTime / duration).clamp(0.0, 1.0) : 0.0;
    _lastKnownProgress = pct;
  }

  Future<void> _saveProgress(double? explicitProgress) async {
    try {
      final savedProgress = explicitProgress ?? _lastKnownProgress ?? 0.0;
      if (title != null) {
        await WatchHistoryService.save(
          tmdbId: tmdbId,
          imdbId: null,
          type: mediaType,
          progress: savedProgress,
          title: title,
          posterPath: posterPath,
          season: season,
          episode: episode,
        );
      }
      await ProgressTracker.saveProgress(tmdbId, savedProgress,
          season: season, episode: episode);
    } catch (e) {
      debugPrint('[PlaybackManager] save progress error: $e');
    }
  }

  ({int season, int episode})? nextEpisode({int? maxEpisodes}) {
    if (!_autoNext || season == null || episode == null) return null;
    final max = maxEpisodes ?? maxEpisodesInSeason;
    final next = EpisodeNavigator.nextEpisode(
      currentSeason: season!,
      currentEpisode: episode!,
      maxEpisodesInSeason: max,
    );
    if (next != null) return next;
    return EpisodeNavigator.nextSeason(
      currentSeason: season!,
      currentEpisode: episode!,
      maxEpisodesInSeason: max,
    );
  }

  Future<void> playNextEpisode(int nextSeason, int nextEpisode) async {
    season = nextSeason;
    episode = nextEpisode;
    _failCount = 0;
    _hasFallenBackToOriginal = false;
    controller.resetRetryCount();
    try {
      _currentServer = await ServerSelector.getBestServerForLanguage(
        tmdbId, _currentLang.code,
      );
    } catch (e) {
      debugPrint('[PlaybackManager] playNextEpisode server error: $e');
      _currentServer = ServerSelector.servers.first.name;
    }
    load();
  }

  void setAutoNext(bool value) {
    _autoNext = value;
    _saveAutoNext(value);
  }

  Future<void> _saveAutoNext(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('player_auto_next', value);
    } catch (e) {
      debugPrint('[PlaybackManager] Error saving autoNext: $e');
    }
  }

  Future<void> loadAutoNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoNext = prefs.getBool('player_auto_next') ?? true;
    } catch (e) {
      debugPrint('[PlaybackManager] Error loading autoNext: $e');
    }
  }

  void toggleSubtitles() {
    _subsEnabled = !_subsEnabled;
    if (!_subsEnabled) _selectedSubtitleTrack = null;
  }

  void setSubtitleTrack(int? index) {
    _selectedSubtitleTrack = index;
    if (index != null) _subsEnabled = true;
  }

  void setQuality(int? index) => _selectedQuality = index;

  void dispose() {
    _isDisposed = true;
    _cancelLoadingTimer();
    _progressTimer?.cancel();
    try {
      urlNotifier.dispose();
    } catch (_) {}
    controller.dispose();
  }
}