import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import '../../core/player/playback_manager.dart';
import '../../core/player/player_controller.dart';
import '../../core/player/language_manager.dart';
import '../../core/player/js_injector.dart';
import '../../core/player/server_selector.dart';
import '../../core/player/hls_parser.dart';
import 'language_selector.dart';
import 'episode_selector.dart';
import 'playback_settings.dart';
import 'autoplay_countdown.dart';
import 'subtitle_selector.dart';
import 'quality_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/sound/sound_provider.dart';
import '../../core/sound/sound_service.dart';
import '../../services/progress_tracker.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final int tmdbId;
  final String mediaType;
  final String title;
  final String? posterPath;
  final int? season;
  final int? episode;
  final Future<List<SeasonInfo>> Function()? onFetchSeasons;
  final Future<List<EpisodeInfo>> Function(int season)? onFetchEpisodes;

  const PlayerScreen({
    super.key,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.season,
    this.episode,
    this.onFetchSeasons,
    this.onFetchEpisodes,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late final PlaybackManager _manager;
  WebViewController? _webViewController;
  late AnimationController _fadeController;
  bool _webViewReady = false;
  bool _controlsVisible = true;
  bool _isPlaying = false;
  bool _showAutoplay = false;
  bool _allowPop = false;
  bool _hasChosenLang = false;
  bool _hasChosenServer = false;
  Timer? _controlsTimer;
  Timer? _reloadDebounce;
  Timer? _stabilizeTimer;
  Timer? _statePollTimer;
  Timer? _autoplayTimer;
  bool _hasStabilized = false;
  String? _embedHost;
  double _volume = 1.0;
  final double _playbackRate = 1.0;
  bool _muted = false;
  double _currentPosition = 0;
  double _totalDuration = 0;
  bool _isSeeking = false;
  bool _showLeftTap = false;
  bool _showRightTap = false;
  Timer? _tapFeedbackTimer;
  List<SubtitleTrackInfo> _subtitleTracks = [];
  List<QualityLevelInfo> _qualityLevels = [];
  bool _isLocked = false;
  bool _showUnlockButton = false;
  Timer? _unlockTimer;
  double _zoomFactor = 1.0;
  double _baseScale = 1.0;

  BetterPlayerController? _betterPlayerController;
  bool _usingNativePlayer = false;
  int _extractRetries = 0;
  bool _nativePlayerReady = false;
  String? _lastExtractedUrl;

  List<BetterPlayerAsmsAudioTrack> _nativeAudioTracks = [];
  BetterPlayerAsmsAudioTrack? _selectedNativeAudioTrack;

  bool get _isFetchingSource => !_webViewReady && !_usingNativePlayer && !_manager.controller.hasError;
  bool get _isLoading => _manager.controller.isLoading || (_usingNativePlayer && !_nativePlayerReady);
  bool get _isBuffering => _usingNativePlayer && (_betterPlayerController?.isBuffering() ?? false);
  bool get _videoReady => _usingNativePlayer ? _nativePlayerReady : _webViewReady;
  bool get _hasError => _manager.controller.hasError;

  void _logState() {
    debugPrint("Loading: $_isLoading");
    debugPrint("Buffering: $_isBuffering");
    debugPrint("Video Ready: $_videoReady");
    debugPrint("Error: $_hasError");
  }

  bool get _showSpinner {
    if (_hasError) return false;
    if (_totalDuration <= 0 && _usingNativePlayer && _nativePlayerReady) return false;
    return _isFetchingSource || _isLoading || _isBuffering;
  }

  static const _allowedExtraHosts = {
    'streamingnow.mov',
  };

  @override
  void initState() {
    super.initState();
    _manager = PlaybackManager(
      tmdbId: widget.tmdbId,
      mediaType: widget.mediaType,
      season: widget.season,
      episode: widget.episode,
      title: widget.title,
      posterPath: widget.posterPath,
    );
    _manager.controller.addListener(_onStateChange);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lockFullscreen();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPrePlayDialogs());
  }

  void _betterPlayerListener(BetterPlayerEvent event) {
    if (!mounted || _betterPlayerController == null) return;

    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      _applyPlaybackSettings();
      _loadNativeAudioTracks();
      _manager.onWebViewReady();
      setState(() {
        _nativePlayerReady = true;
        _usingNativePlayer = true;
      });
      _autoResumeNativePlayer();
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      _onVideoFinished();
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      debugPrint('[Player] BetterPlayer error: ${event.parameters}');
      _cleanupBetterPlayerController();
      _completeWebViewSetup();
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      setState(() {
        _isPlaying = true;
      });
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
      setState(() {
        _isPlaying = false;
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _autoResumeNativePlayer() async {
    if (!mounted) return;
    final ctrl = _betterPlayerController;
    final vpc = ctrl?.videoPlayerController;
    if (vpc == null) return;
    try {
      final savedProgress = await ProgressTracker.getProgress(
        widget.tmdbId,
        season: widget.season,
        episode: widget.episode,
      );
      if (!mounted || savedProgress <= 0.01) return;

      final duration = vpc.value.duration;
      if (duration == null || duration.inSeconds < 5) return;

      final seekMs = (savedProgress * duration.inMilliseconds).round();
      if (seekMs < 5000) return; // skip if < 5s from start

      await ctrl!.seekTo(Duration(milliseconds: seekMs));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Continuando reproducción desde ${_formatDurationObj(Duration(milliseconds: seekMs))}',
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Player] Auto-resume error: $e');
    }
  }

  String _formatDurationObj(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _cleanupBetterPlayerController() {
    if (_betterPlayerController != null) {
      try {
        _betterPlayerController!.removeEventsListener(_betterPlayerListener);
      } catch (e) {
        debugPrint('[Player] Error removing BetterPlayer listener: $e');
      }
      try {
        _betterPlayerController!.pause();
      } catch (e) {
        debugPrint('[Player] Error pausing BetterPlayer: $e');
      }
      try {
        _betterPlayerController!.dispose();
      } catch (e) {
        debugPrint('[Player] Error disposing BetterPlayer: $e');
      }
      _betterPlayerController = null;
    }
  }

  // ────────────────────────────────────────────────────────────────
  //  Memory cleanup
  // ────────────────────────────────────────────────────────────────
  void _cleanupResources() {
    debugPrint('[Player] _cleanupResources');

    _cleanupBetterPlayerController();

    _webViewController?.clearCache();
    _webViewController?.loadRequest(Uri.parse('about:blank'));
    _webViewController = null;

    _controlsTimer?.cancel();
    _controlsTimer = null;
    _reloadDebounce?.cancel();
    _reloadDebounce = null;
    _stabilizeTimer?.cancel();
    _stabilizeTimer = null;
    _statePollTimer?.cancel();
    _statePollTimer = null;
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
    _tapFeedbackTimer?.cancel();
    _tapFeedbackTimer = null;
    _unlockTimer?.cancel();
    _unlockTimer = null;

    _webViewReady = false;
    _hasStabilized = false;
    _usingNativePlayer = false;
    _nativePlayerReady = false;
    _isLocked = false;
    _showUnlockButton = false;
    _extractRetries = 0;
    _embedHost = null;
    _currentPosition = 0;
    _totalDuration = 0;
    _showAutoplay = false;
    _nativeAudioTracks = [];
    _selectedNativeAudioTrack = null;
    _subtitleTracks = [];
    _qualityLevels = [];
    _isPlaying = false;
    _lastExtractedUrl = null;
  }


  Future<void> _showPrePlayDialogs() async {
    await _showLanguageFirst();
    if (mounted) {
      // Initialize manager to load preferred language and resolve the default server
      await _manager.init();
    }
    if (mounted) {
      await _showServerThenLoad();
    }
  }

  Future<void> _showLanguageFirst() async {
    final lang = await showModalBottomSheet<PlayerLanguage>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => LanguageSelector(manager: _manager),
    );
    if (lang != null && mounted) {
      await _manager.changeLanguage(lang);
      setState(() => _hasChosenLang = true);
    } else if (mounted) {
      setState(() => _hasChosenLang = true);
    }
  }

  Future<void> _showServerThenLoad() async {
    final currentLang = _manager.currentLang.code;
    final servers = (currentLang == 'ORIGINAL' || currentLang.isEmpty)
        ? ServerSelector.serverNames
        : ServerSelector.serversForLanguage(currentLang, tmdbId: widget.tmdbId).map((s) => s.name).toList();
    final current = _manager.currentServer;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('Seleccionar servidor',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15, fontWeight: FontWeight.w600,
                    )),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: servers.length,
                  itemBuilder: (_, i) {
                    final s = servers[i];
                    final isActive = s == current;
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          ),
                          child: isActive
                              ? const Icon(Icons.check, color: Colors.white, size: 12)
                              : null,
                        ),
                        title: Text(s, style: TextStyle(
                          color: Colors.white.withValues(alpha: isActive ? 0.95 : 0.7),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        )),
                        subtitle: Text(
                          isActive ? 'Recomendado para este idioma' : 'Tocar para cambiar',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                        ),
                        onTap: () => Navigator.pop(ctx, s),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != current && mounted) {
      await _manager.changeServerManual(selected);
    }
    if (mounted) {
      setState(() => _hasChosenServer = true);
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    try {
      _cleanupResources();
      await _manager.init();

      _usingNativePlayer = false;
      _nativePlayerReady = false;
      _webViewReady = false;

      _startWebView();
      _manager.load();
      _startStatePolling();
    } catch (e) {
      debugPrint('[Player] _initPlayer error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al iniciar el reproductor: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _startStatePolling() {
    _statePollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || _isSeeking) return;

      if (_usingNativePlayer && _betterPlayerController != null) {
        try {
          if (!_nativePlayerReady) return;
          final ctrl = _betterPlayerController!;
          final vpc = ctrl.videoPlayerController;
          if (vpc == null) return;
          final val = vpc.value;
          if (val.hasError) return;
          if (mounted) {
            setState(() {
              _currentPosition = val.position.inMilliseconds / 1000.0;
              _totalDuration = (val.duration?.inMilliseconds ?? 0) / 1000.0;
              _isPlaying = val.isPlaying;
            });
            _manager.reportPlaybackPosition(_currentPosition, _totalDuration);
          }
        } catch (e) {
          debugPrint('[Player] State polling error: $e');
        }
        return;
      }

      if (_webViewReady && _webViewController != null) {
        final result = await _webViewController!
            .runJavaScriptReturningResult('''
(function() {
  function findVideo(root) {
    root = root || document;
    var v = root.querySelector('video');
    if (v) return v;
    var iframes = root.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      try {
        var doc = iframes[i].contentDocument;
        if (doc) {
          v = doc.querySelector('video');
          if (v) return v;
        }
      } catch(e) {}
    }
    return null;
  }
  var v = findVideo();
  if (v) {
    return JSON.stringify({paused: v.paused, ended: v.ended, time: v.currentTime, duration: v.duration});
  }
  return '{}';
})();
''');
        try {
          var str = result.toString();
          if (str.startsWith('"') && str.endsWith('"')) {
            str = str.substring(1, str.length - 1);
          }
          str = str.replaceAll('\\"', '"');
          final data = jsonDecode(str) as Map<String, dynamic>;
          final time = (data['time'] as num?)?.toDouble() ?? 0;
          final duration = (data['duration'] as num?)?.toDouble() ?? 0;
          if (mounted) {
            setState(() {
              _currentPosition = time;
              _totalDuration = duration;
            });
          }
          if (duration > 0) {
            _manager.reportPlaybackPosition(time, duration);
          }
        } catch (_) {}
      }
    });
  }

  void _onVideoFinished() {
    if (!mounted) return;
    debugPrint('[Player] Video finished');
    if (_manager.autoNext && widget.mediaType == 'tv') {
      setState(() => _showAutoplay = true);
      _autoplayTimer?.cancel();
      _autoplayTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) _playNextEpisode();
      });
    }
  }

  void _startWebView() {
    final url = _manager.urlForCurrentState;
    _embedHost = Uri.tryParse(url)?.host;
    debugPrint('[Player] _startWebView: url=$url lang=${_manager.currentLang.code} server=${_manager.currentServer}');

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url.startsWith('about:blank')) return NavigationDecision.navigate;
          final target = Uri.tryParse(request.url)?.host;
          if (target == null || _embedHost == null) return NavigationDecision.navigate;

          final isEmbed = target == _embedHost || target.endsWith('.$_embedHost');
          final isAllowed = _allowedExtraHosts.contains(target);

          final isAdDomain = target.contains('doubleclick') ||
              target.contains('googleads') ||
              target.contains('adserver') ||
              target.contains('adservice') ||
              target.contains('googlesyndication') ||
              target.contains('adsafeprotected') ||
              target.contains('analytics') ||
              target.contains('yandex') ||
              target.contains('cloudflareinsights');

          if (isAdDomain) return NavigationDecision.prevent;
          if (isEmbed || isAllowed) return NavigationDecision.navigate;

          return NavigationDecision.prevent;
        },
        onPageStarted: (_) {
          if (_webViewReady) {
            _webViewReady = false;
            _hasStabilized = false;
            _stabilizeTimer?.cancel();
          }
        },
        onPageFinished: (_) {
          _injectJs();
          _tryStabilize();
        },
        onWebResourceError: (error) {
          if (!(error.isForMainFrame ?? false)) return;

          debugPrint('[Player] Error crítico MainFrame: ${error.errorCode} url=${error.url}');
          if (!_hasStabilized) {
            _manager.onPageLoadError('Error ${error.errorCode}');
          }
        },
      ))
      ..addJavaScriptChannel('PlayerBridge',
        onMessageReceived: (msg) {
          _onExtractionResult(msg.message, _manager.currentServer);
        },
      )
      ..loadRequest(Uri.parse(url));

    _webViewController?.setOnConsoleMessage((msg) {
      final text = msg.message;
      if (text.contains('[forceLanguage]') || text.contains('[langPolling]') || text.contains('[extractVideoSource]')) {
        debugPrint('[Player JS] $text');
      }
    });

    if (_webViewController!.platform is AndroidWebViewController) {
      final android = _webViewController!.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
      android.setMixedContentMode(MixedContentMode.alwaysAllow);
    }
  }

  void _tryStabilize() {
    if (_hasStabilized || _webViewReady) return;
    _stabilizeTimer?.cancel();
    _stabilizeTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted || _webViewReady) return;
      final hasVideo = await _checkForVideo();
      if (hasVideo && !_webViewReady && mounted) {
        _hasStabilized = true;
        _webViewReady = true;
        _manager.onWebViewReady();
        // Try to select a Spanish source before extracting
        final requestServer = _manager.currentServer;
        _webViewController?.runJavaScriptReturningResult(
          JsInjector.selectSpanishSource(),
        ).then((result) async {
          if (requestServer != _manager.currentServer || !mounted) {
            debugPrint('[Player] Server changed during selectSpanishSource. Aborting.');
            return;
          }
          debugPrint('[Player] Spanish source selection result: $result');
          
          bool spanishFound = false;
          try {
            var str = result.toString();
            if (str.startsWith('"') && str.endsWith('"')) {
              str = str.substring(1, str.length - 1);
            }
            str = str.replaceAll('\\"', '"');
            final data = jsonDecode(str) as Map<String, dynamic>;
            spanishFound = data['spanishFound'] == true;
          } catch (e) {
            debugPrint('[Player] Error parsing Spanish selection result: $e');
          }
          
          if (spanishFound) {
            debugPrint('[Player] Spanish source clicked, waiting for stream reload...');
            await Future.delayed(const Duration(milliseconds: 2500));
          }
          
          if (mounted && requestServer == _manager.currentServer) {
            _attemptVideoExtraction();
          }
        }).catchError((err) {
          if (requestServer != _manager.currentServer || !mounted) return;
          debugPrint('[Player] Error running selectSpanishSource: $err');
          if (mounted) {
            _attemptVideoExtraction();
          }
        });
      } else if (mounted && !_webViewReady) {
        _tryStabilize();
      }
    });
  }

  void _attemptVideoExtraction() {
    _extractRetries = 0;
    _runExtraction();
  }

  void _runExtraction() {
    if (!mounted || _usingNativePlayer) return;
    final extractionServer = _manager.currentServer;
    _webViewController
        ?.runJavaScriptReturningResult(JsInjector.extractVideoSource())
        .then((result) {
      if (!mounted || _usingNativePlayer || extractionServer != _manager.currentServer) return;
      var str = result.toString();
      if (str.startsWith('"') && str.endsWith('"')) {
        str = str.substring(1, str.length - 1);
      }
      str = str.replaceAll('\\"', '"').replaceAll('\\n', '').replaceAll('\\t', '');
      _onExtractionResult(str, extractionServer);
    }).catchError((_) {
      if (extractionServer != _manager.currentServer || !mounted) return;
      _retryExtraction();
    });
  }

  void _onExtractionResult(String json, String extractionServer) async {
    if (extractionServer != _manager.currentServer || !mounted) return;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final hasVideo = data['hasVideo'] == true;
      final src = (data['src'] as String?) ?? '';
      final hlsUrl = (data['hlsUrl'] as String?) ?? '';
      final videoUrl = hlsUrl.isNotEmpty ? hlsUrl : src;
      final headers = (data['headers'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};

      if (videoUrl.isNotEmpty) {
        debugPrint('[Player] Extraction success: $videoUrl');
        await _switchToNativePlayer(videoUrl, headers: headers);
        return;
      }

      if (hasVideo) {
        _retryExtraction();
      } else {
        _retryExtraction();
      }
    } catch (_) {
      _retryExtraction();
    }
  }

  void _retryExtraction() {
    if (!mounted) return;
    _extractRetries++;
    if (_extractRetries >= 3) {
      debugPrint('[Player] Extraction failed after $_extractRetries attempts, falling back to WebView');
      _completeWebViewSetup();
      return;
    }
    Future.delayed(const Duration(milliseconds: 1500), _runExtraction);
  }

  void _completeWebViewSetup() {
    if (!mounted || _usingNativePlayer) return;
    setState(() {
      _webViewReady = true;
      _usingNativePlayer = false;
    });
    _manager.onWebViewReady(); // <- Update player controller state to PlayState.loaded
    _fadeController.forward();
    _showControlsBriefly();
    _applyPlaybackSettings();
    _applyLanguage();
    _fetchSubtitleTracks();
    _fetchQualityLevels();
  }

  Future<void> _switchToNativePlayer(String url, {Map<String, String>? headers}) async {
    if (!mounted) return;
    if (_lastExtractedUrl == url) {
      debugPrint('[Player] _switchToNativePlayer: URL is identical to last extracted. Skipping.');
      return;
    }
    _lastExtractedUrl = url;

    if (_betterPlayerController != null) {
      debugPrint('[Player] _switchToNativePlayer: New URL extracted. Disposing old native player.');
      _cleanupBetterPlayerController();
      setState(() {
        _nativePlayerReady = false;
      });
    }

    await _webViewController?.runJavaScript('window.stop();');
    await _webViewController?.loadRequest(Uri.parse('about:blank'));
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final Map<String, String> finalHeaders = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Referer': headers?['Referer'] ?? (headers?['referer'] ?? (_embedHost != null ? 'https://$_embedHost/' : 'https://vidlink.pro/')),
      'Origin': headers?['Origin'] ?? (headers?['origin'] ?? (_embedHost != null ? 'https://$_embedHost' : 'https://vidlink.pro')),
      ...?headers,
    };

    final extractionServer = _manager.currentServer;
    String finalUrl = url;
    if (url.contains('.m3u8')) {
      debugPrint('[Player] Downloading HLS manifest for Spanish track search...');
      try {
        final response = await http.get(Uri.parse(url), headers: finalHeaders);
        if (extractionServer != _manager.currentServer || !mounted) {
          debugPrint('[Player] Server changed during HLS manifest download. Aborting.');
          return;
        }
        if (response.statusCode == 200) {
          final result = HlsParser.findSpanishTrack(response.body, originalUri: url);
          if (result.spanishFound) {
            debugPrint('[Player] Spanish audio track resolved: ${result.url}');
          }
          if (result.isMasterPlaylist) {
            finalUrl = result.url;
          }
        }
      } catch (e) {
        debugPrint('[Player] HLS manifest download failed: $e');
      }
    }

    if (extractionServer != _manager.currentServer || !mounted) {
      debugPrint('[Player] Server changed during resolution. Aborting native player startup.');
      return;
    }

    debugPrint('[Player] Playing final stream via BetterPlayer: $finalUrl');

    const betterPlayerConfiguration = BetterPlayerConfiguration(
      autoPlay: true,
      fit: BoxFit.contain,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
      ),
    );

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      finalUrl,
      headers: finalHeaders,
      useAsmsAudioTracks: true,
    );

    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: dataSource,
    );

    _betterPlayerController!.addEventsListener(_betterPlayerListener);

    _fadeController.forward();
    _showControlsBriefly();

    setState(() {
      _usingNativePlayer = true;
    });
  }

  Future<void> _loadNativeAudioTracks() async {
    if (!_usingNativePlayer) return;
    final ctrl = _betterPlayerController;
    if (ctrl == null) return;
    final tracks = ctrl.betterPlayerAsmsAudioTracks ?? [];
    final selectedTrack = ctrl.betterPlayerAsmsAudioTrack;
    if (mounted) {
      setState(() {
        _nativeAudioTracks = tracks;
        _selectedNativeAudioTrack = selectedTrack;
      });
    }
    // Auto-select Spanish track if available
    final lang = _manager.currentLang;
    if (lang.code.toUpperCase().startsWith('ES')) {
      final keywords = ['es', 'spa', 'spanish', 'español', 'latino', 'castellano'];
      BetterPlayerAsmsAudioTrack? spanishTrack;
      for (final track in tracks) {
        final label = (track.label ?? '').toLowerCase();
        final language = (track.language ?? '').toLowerCase();
        if (keywords.any((kw) => label.contains(kw) || language.contains(kw))) {
          spanishTrack = track;
          break;
        }
      }
      if (spanishTrack != null && spanishTrack != selectedTrack) {
        ctrl.setAudioTrack(spanishTrack);
        if (mounted) {
          setState(() => _selectedNativeAudioTrack = spanishTrack);
        }
        debugPrint('[Player] Auto-selected Spanish track: ${spanishTrack.label}');
      }
    }
  }

  void _showNativeAudioTracks() async {
    await _loadNativeAudioTracks();
    if (!mounted || _nativeAudioTracks.isEmpty) return;

    final selected = await showModalBottomSheet<BetterPlayerAsmsAudioTrack>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _buildNativeAudioTrackSheet(ctx),
    );

    if (selected != null && mounted) {
      final ctrl = _betterPlayerController;
      if (ctrl != null) {
        ctrl.setAudioTrack(selected);
        await _loadNativeAudioTracks();
      }
    }
  }

  Widget _buildNativeAudioTrackSheet(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Pista de audio',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _nativeAudioTracks.length,
              itemBuilder: (_, i) {
                final track = _nativeAudioTracks[i];
                final isSelected = track == _selectedNativeAudioTrack;
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  title: Text(
                    (track.label != null && track.label!.isNotEmpty) ? track.label! : 'Pista ${track.id}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, track),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<bool> _checkForVideo() async {
    try {
      final result = await _webViewController?.runJavaScriptReturningResult('''
(function() {
  var v = document.querySelector('video');
  if (v && v.readyState >= 1) return true;
  var iframes = document.querySelectorAll('iframe');
  for (var i = 0; i < iframes.length; i++) {
    try {
      var doc = iframes[i].contentDocument;
      if (doc) {
        var iv = doc.querySelector('video');
        if (iv && iv.readyState >= 1) return true;
      }
    } catch(e) {}
  }
  return false;
})();
''');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  void _injectJs() {
    final lang = _manager.currentLang;
    debugPrint('[Player] _injectJs: lang=${lang.code} bcp47=${lang.bcp47}');

    _webViewController?.runJavaScript(JsInjector.hideAds());

    if (lang.code != 'ORIGINAL') {
      _webViewController?.runJavaScript(
        JsInjector.startLanguagePolling(lang.code, lang.bcp47),
      );
    }
  }

  Future<void> _applyLanguage() async {
    final lang = _manager.currentLang;
    debugPrint('[Player] _applyLanguage: ${lang.code}');

    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      if (ctrl == null) return;
      final tracks = ctrl.betterPlayerAsmsAudioTracks ?? [];
      if (tracks.isNotEmpty) {
        final isSpanish = lang.code.toUpperCase().startsWith('ES');
        final keywords = isSpanish
            ? ['es', 'spa', 'spanish', 'español', 'latino', 'castellano']
            : [lang.code.toLowerCase(), lang.bcp47.toLowerCase()];
        BetterPlayerAsmsAudioTrack? selectedTrack;
        for (final track in tracks) {
          final label = (track.label ?? '').toLowerCase();
          final language = (track.language ?? '').toLowerCase();
          if (keywords.any((kw) => label.contains(kw) || language.contains(kw))) {
            selectedTrack = track;
            break;
          }
        }
        if (selectedTrack != null) {
          ctrl.setAudioTrack(selectedTrack);
          debugPrint('[Player] Audio track auto-selected: ${selectedTrack.label}');
        }
      }
      return;
    }

    _webViewController?.runJavaScript(JsInjector.startLanguagePolling(lang.code, lang.bcp47));
  }

  Future<void> _fetchSubtitleTracks() async {
    if (_usingNativePlayer) {
      setState(() {
        _subtitleTracks = [];
      });
      return;
    }
    try {
      final result = await _webViewController?.runJavaScriptReturningResult(
        JsInjector.getSubtitleTracks(),
      );
      if (result != null) {
        var str = result.toString();
        if (str.startsWith('"') && str.endsWith('"')) {
          str = str.substring(1, str.length - 1);
        }
        str = str.replaceAll('\\"', '"');
        final list = (jsonDecode(str) as List).cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            _subtitleTracks = list.map((e) => SubtitleTrackInfo.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('[Player] _fetchSubtitleTracks error: $e');
    }
  }

  Future<void> _fetchQualityLevels() async {
    if (_usingNativePlayer) {
      setState(() {
        _qualityLevels = [];
      });
      return;
    }
    try {
      final result = await _webViewController?.runJavaScriptReturningResult(
        JsInjector.getQualityLevels(),
      );
      if (result != null) {
        var str = result.toString();
        if (str.startsWith('"') && str.endsWith('"')) {
          str = str.substring(1, str.length - 1);
        }
        str = str.replaceAll('\\"', '"');
        final list = (jsonDecode(str) as List).cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            _qualityLevels = list.map((e) => QualityLevelInfo.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('[Player] _fetchQualityLevels error: $e');
    }
  }

  void _applySubtitleToggle() {
    if (_usingNativePlayer) {
      return;
    }
    _webViewController?.runJavaScript(
      JsInjector.toggleSubtitles(_manager.subsEnabled),
    );
  }

  void _applySubtitleTrack(int? index) {
    if (_usingNativePlayer) {
      return;
    }
    if (index != null) {
      _webViewController?.runJavaScript(JsInjector.setSubtitleTrack(index));
    } else {
      _applySubtitleToggle();
    }
  }

  void _applyQuality(int? index) {
    if (_usingNativePlayer) {
      return;
    }
    if (index != null) {
      _webViewController?.runJavaScript(JsInjector.setQualityLevel(index));
    }
  }

  Future<void> _showSubtitleSelector() async {
    await _fetchSubtitleTracks();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SubtitleSelector(
        manager: _manager,
        tracks: _subtitleTracks,
        subsEnabled: _manager.subsEnabled,
        onToggleSubtitles: (enabled) {
          _manager.toggleSubtitles();
          _applySubtitleToggle();
          Navigator.pop(context);
        },
        onSelectTrack: (index) {
          _manager.setSubtitleTrack(index);
          _applySubtitleTrack(index);
          Navigator.pop(context);
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showQualitySelector() async {
    await _fetchQualityLevels();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => QualitySelector(
        manager: _manager,
        levels: _qualityLevels,
        onSelectQuality: (index) {
          _manager.setQuality(index);
          _applyQuality(index);
          Navigator.pop(context);
        },
      ),
    );
    if (mounted) setState(() {});
  }

  void _applyPlaybackSettings() {
    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      if (ctrl == null) return;
      ctrl.setVolume(_muted ? 0.0 : _volume);
      ctrl.setSpeed(_playbackRate);
      return;
    }
    _webViewController?.runJavaScript('''
(function() {
  function findVideo(root) {
    root = root || document;
    var v = root.querySelector('video');
    if (v) return v;
    var iframes = root.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      try {
        var doc = iframes[i].contentDocument;
        if (doc) {
          v = doc.querySelector('video');
          if (v) return v;
        }
      } catch(e) {}
    }
    return null;
  }
  var v = findVideo();
  if (v) {
    v.volume = $_volume;
    v.muted = $_muted;
    v.playbackRate = $_playbackRate;
  }
})();
''');
  }

  void _reloadWebView() {
    _cleanupResources();
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final url = _manager.urlForCurrentState;
      debugPrint('[Player] _reloadWebView: url=$url lang=${_manager.currentLang.code} server=${_manager.currentServer}');
      _embedHost = Uri.tryParse(url)?.host;
      _startWebView();
      _fadeController.reset();
      _showAutoplay = false;
      _manager.load();
    });
  }

  void _onStateChange() {
    if (mounted) setState(() {});
    final state = _manager.controller.state;
    if (state == PlayState.switchingServer) {
      _reloadWebView();
    }
  }

  void _showControlsBriefly() {
    setState(() => _controlsVisible = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    if (_isLocked) {
      setState(() {
        _showUnlockButton = !_showUnlockButton;
        if (_showUnlockButton) {
          _startUnlockTimer();
        }
      });
      return;
    }
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      _controlsTimer?.cancel();
      _controlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  Future<void> _showLanguageSelector() async {
    if (_usingNativePlayer) {
      await _loadNativeAudioTracks();
      if (_nativeAudioTracks.length > 1) {
        if (!mounted) return;
        final option = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: const Color(0xFF1A1A2E),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Opciones de Audio',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack_rounded, color: Colors.white),
                title: const Text('Cambiar pista de audio del video actual',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Selecciona entre los canales de audio embebidos en este archivo (ej: Español / Inglés).',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, 'tracks'),
              ),
              ListTile(
                leading: const Icon(Icons.translate_rounded, color: Colors.white),
                title: const Text('Cambiar idioma del servidor (Recargar)',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Pide al servidor otra versión del video en el idioma seleccionado (ej: Español Latino).',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, 'source'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );

        if (option == 'tracks') {
          _showNativeAudioTracks();
          return;
        } else if (option == 'source') {
          await _showSourceLanguageSelector();
          return;
        }
        return;
      }
    }

    await _showSourceLanguageSelector();
  }

  Future<void> _showSourceLanguageSelector() async {
    final lang = await showModalBottomSheet<PlayerLanguage>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => LanguageSelector(manager: _manager),
    );
    if (lang != null && mounted) {
      await _manager.changeLanguage(lang);
      if (_usingNativePlayer) {
        _initPlayer();
      } else {
        _reloadWebView();
      }
    }
  }

  Future<void> _showServerSelector() async {
    final currentLang = _manager.currentLang.code;
    final servers = (currentLang == 'ORIGINAL' || currentLang.isEmpty)
        ? ServerSelector.serverNames
        : ServerSelector.serversForLanguage(currentLang, tmdbId: widget.tmdbId).map((s) => s.name).toList();
    final current = _manager.currentServer;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('Servidores disponibles',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15, fontWeight: FontWeight.w600,
                    )),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: servers.length,
                  itemBuilder: (_, i) {
                    final s = servers[i];
                    final isActive = s == current;
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          ),
                          child: isActive
                              ? const Icon(Icons.check, color: Colors.white, size: 12)
                              : null,
                        ),
                        title: Text(s, style: TextStyle(
                          color: Colors.white.withValues(alpha: isActive ? 0.95 : 0.7),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        )),
                        subtitle: Text(
                          isActive ? 'Activo' : 'Tocar para cambiar',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                        ),
                        onTap: () => Navigator.pop(ctx, s),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != current && mounted) {
      await _manager.changeServerManual(selected);
      _reloadWebView();
    }
  }

  Future<void> _showSettings() async {
    final previousSubs = _manager.subsEnabled;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PlaybackSettings(manager: _manager),
    );
    if (mounted) {
      if (_manager.subsEnabled != previousSubs) {
        _applySubtitleToggle();
      }
      setState(() {});
    }
  }

  void _showVolumeSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: 128,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _muted = !_muted;
                      _applyPlaybackSettings();
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Volumen',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '${(_muted ? 0 : _volume * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: _muted ? 0 : _volume,
                  onChanged: (v) {
                    setState(() {
                      _volume = v;
                      _muted = false;
                    });
                    _applyPlaybackSettings();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showZoomControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Zoom de Pantalla',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(_zoomFactor * 100).round()}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _zoomFactor = (_zoomFactor - 0.1).clamp(0.5, 2.5);
                        });
                        setSheetState(() {});
                      },
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Slider(
                          value: _zoomFactor,
                          min: 0.5,
                          max: 2.5,
                          divisions: 20,
                          onChanged: (v) {
                            setState(() {
                              _zoomFactor = v;
                            });
                            setSheetState(() {});
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _zoomFactor = (_zoomFactor + 0.1).clamp(0.5, 2.5);
                        });
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _zoomFactor = 1.0;
                    });
                    setSheetState(() {});
                  },
                  icon: const Icon(Icons.settings_backup_restore_rounded, color: Colors.white70, size: 16),
                  label: const Text('Restablecer', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEpisodeSelector() async {
    if (widget.onFetchSeasons == null || widget.onFetchEpisodes == null) return;
    List<SeasonInfo> seasons;
    try {
      seasons = await widget.onFetchSeasons!();
    } catch (e) {
      debugPrint('[Player] Error fetching seasons: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cargar temporadas: $e'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => EpisodeSelector(
        seasons: seasons,
        currentSeason: _manager.season ?? 1,
        currentEpisode: _manager.episode ?? 1,
        onFetchEpisodes: widget.onFetchEpisodes!,
        onSelectEpisode: (s, e) {
          if (!mounted) return;
          _showAutoplay = false;
          _autoplayTimer?.cancel();
          _manager.playNextEpisode(s, e);
          _reloadWebView();
        },
      ),
    );
  }

  void _togglePlayPause() {
    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      if (ctrl == null) return;
      if (_isPlaying) {
        ctrl.pause();
      } else {
        ctrl.play();
      }
      return;
    }
    setState(() => _isPlaying = !_isPlaying);
    _webViewController?.runJavaScript('''
(function() {
  function findVideo(root) {
    root = root || document;
    var v = root.querySelector('video');
    if (v) return v;
    var iframes = root.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      try {
        var doc = iframes[i].contentDocument;
        if (doc) {
          v = doc.querySelector('video');
          if (v) return v;
        }
      } catch(e) {}
    }
    return null;
  }
  var v = findVideo();
  if (v) {
    if (v.paused) { v.play(); } else { v.pause(); }
  }
})();
''');
  }

  void _playNextEpisode() {
    final next = _manager.nextEpisode();
    if (next != null) {
      _showAutoplay = false;
      _autoplayTimer?.cancel();
      _manager.playNextEpisode(next.season, next.episode);
      _reloadWebView();
    }
  }

  void _cancelAutoplay() {
    setState(() => _showAutoplay = false);
    _autoplayTimer?.cancel();
  }

  void _lockFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _restoreOrientation();
    _cleanupResources();
    _fadeController.dispose();
    _unlockTimer?.cancel();
    _manager.controller.removeListener(_onStateChange);
    _manager.dispose();
    super.dispose();
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _controlsVisible = false;
        _showUnlockButton = true;
        _startUnlockTimer();
      } else {
        _controlsVisible = true;
        _showUnlockButton = false;
        _unlockTimer?.cancel();
        _showControlsBriefly();
      }
    });
  }

  void _startUnlockTimer() {
    _unlockTimer?.cancel();
    _unlockTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showUnlockButton = false);
      }
    });
  }

  void _onDoubleTapDown(TapDownDetails details) {
    if (_isLocked || !_webViewReady) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;
    if (tapX < screenWidth / 2) {
      _skipBackward();
      setState(() => _showLeftTap = true);
      _tapFeedbackTimer?.cancel();
      _tapFeedbackTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showLeftTap = false);
      });
    } else {
      _skipForward();
      setState(() => _showRightTap = true);
      _tapFeedbackTimer?.cancel();
      _tapFeedbackTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showRightTap = false);
      });
    }
  }

  Future<bool?> _showExitConfirmationDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.exitPlayerTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          l10n.exitPlayerMessage,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx, false);
            },
            child: Text(l10n.continueWatching, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx, true);
            },
            child: Text(l10n.exit, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _onBackPress() async {
    final confirm = await _showExitConfirmationDialog();
    if (confirm == true && mounted) {
      setState(() {
        _allowPop = true;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _logState();
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          onDoubleTapDown: _onDoubleTapDown,
          child: Stack(
            children: [
              Positioned.fill(child: _buildVideoArea()),
              if (_webViewReady || _nativePlayerReady || _manager.controller.state == PlayState.loading || _manager.controller.state == PlayState.switchingServer)
                Positioned.fill(child: _buildControlsOverlay()),
              if (_manager.controller.hasError)
                Positioned.fill(child: _buildErrorOverlay()),
              if (_hasChosenLang && _hasChosenServer && !_manager.controller.hasError && !_usingNativePlayer && _showSpinner)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              if (_showAutoplay)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildAutoplayBar(),
                ),
              if (_showLeftTap)
                Positioned(
                  left: 24,
                  top: 0,
                  bottom: 0,
                  child: _buildTapFeedbackIcon(Icons.replay_10, '-10s'),
                ),
              if (_showRightTap)
                Positioned(
                  right: 24,
                  top: 0,
                  bottom: 0,
                  child: _buildTapFeedbackIcon(Icons.forward_10, '+10s'),
                ),
              if (_isLocked && _showUnlockButton)
                Positioned(
                  top: 24,
                  left: 24,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleLock,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.6),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const Icon(Icons.lock_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildVideoArea() {
    Widget playerWidget;
    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      if (ctrl != null) {
        playerWidget = BetterPlayer(controller: ctrl);
      } else {
        playerWidget = const SizedBox.shrink();
      }
    } else if (_webViewController != null) {
      playerWidget = AnimatedBuilder(
        animation: _fadeController,
        builder: (_, __) => Opacity(
          opacity: _fadeController.value,
          child: _webViewReady ? WebViewWidget(controller: _webViewController!) : null,
        ),
      );
    } else {
      playerWidget = const SizedBox.shrink();
    }

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _zoomFactor;
      },
      onScaleUpdate: (details) {
        setState(() {
          _zoomFactor = (_baseScale * details.scale).clamp(0.5, 2.5);
        });
      },
      child: ClipRect(
        child: Transform.scale(
          scale: _zoomFactor,
          child: playerWidget,
        ),
      ),
    );
  }


  Widget _buildErrorOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline_rounded, size: 36, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _manager.controller.stateLabel(langCode: Localizations.localeOf(context).languageCode),
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${Localizations.localeOf(context).languageCode == 'es' ? 'Servidores probados' : 'Servers tried'}: ${_manager.failCount}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () {
                      _manager.retry();
                      _reloadWebView();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reintentar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _onBackPress,
                    child: Text(
                      'Volver',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoplayBar() {
    final next = _manager.nextEpisode();
    if (next == null) return const SizedBox.shrink();
    return AutoplayCountdown(
      title: widget.title,
      nextSeason: next.season,
      nextEpisode: next.episode,
      onPlay: _playNextEpisode,
      onCancel: _cancelAutoplay,
    );
  }

  Widget _buildControlsOverlay() {
    return IgnorePointer(
      ignoring: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          children: [
            _buildTopBar(),
            _buildCenterControls(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTapFeedbackIcon(IconData icon, String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: _onBackPress,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.mediaType == 'tv')
                    IconButton(
                      icon: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 22),
                      tooltip: 'Episodios',
                      onPressed: _showEpisodeSelector,
                    ),
                  IconButton(
                    icon: Icon(
                      _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    tooltip: _isLocked ? 'Desbloquear controles' : 'Bloquear controles',
                    onPressed: _toggleLock,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 5),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    final isTv = widget.mediaType == 'tv';
    final hasPrev = isTv && _hasPrevEpisode();
    final hasNext = isTv && _hasNextEpisode();
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isTv)
            _centerEpisodeButton(
              Icons.skip_previous_rounded,
              hasPrev ? _playPreviousEpisode : null,
              tooltip: 'Episodio anterior',
            ),
          if (isTv) const SizedBox(width: 12),
          _centerControlButton(Icons.replay_10, _skipBackward),
          const SizedBox(width: 24),
          _playPauseButton(),
          const SizedBox(width: 24),
          _centerControlButton(Icons.forward_10, _skipForward),
          if (isTv) const SizedBox(width: 12),
          if (isTv)
            _centerEpisodeButton(
              Icons.skip_next_rounded,
              hasNext ? _playNextEpisode : null,
              tooltip: 'Siguiente episodio',
            ),
        ],
      ),
    );
  }

  bool _hasPrevEpisode() {
    final s = _manager.season;
    final e = _manager.episode;
    if (s == null || e == null) return false;
    return e > 1 || s > 1;
  }

  bool _hasNextEpisode() {
    return _manager.nextEpisode() != null;
  }

  void _playPreviousEpisode() {
    final s = _manager.season;
    final e = _manager.episode;
    if (s == null || e == null) return;
    setState(() {
      _showAutoplay = false;
    });
    _autoplayTimer?.cancel();
    if (e > 1) {
      _manager.playNextEpisode(s, e - 1);
    } else if (s > 1) {
      // Go to last episode of previous season – use 99 as upper bound,
      // the server will cap to the actual last episode.
      _manager.playNextEpisode(s - 1, 1);
    }
    _reloadWebView();
  }

  Widget _centerEpisodeButton(IconData icon, VoidCallback? onTap, {String? tooltip}) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: enabled ? 0.4 : 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: enabled ? 0.15 : 0.05),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.3),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerControlButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _playPauseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _togglePlayPause,
        customBorder: const CircleBorder(),
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.black,
            size: 38,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_totalDuration > 0) _buildSeekBar(),
                  Row(
                    children: [
                      Text(
                        '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 _compactButton(
                                  Icons.language_rounded,
                                  _usingNativePlayer && _selectedNativeAudioTrack != null
                                      ? _shortenLanguageLabel(_selectedNativeAudioTrack!.label ?? _manager.currentLang.label)
                                      : _shortenLanguageLabel(_manager.currentLang.label),
                                  _showLanguageSelector,
                                ),
                                const SizedBox(width: 8),
                                _compactButton(Icons.subtitles_rounded, 'Subs', _showSubtitleSelector),
                                const SizedBox(width: 8),
                                _compactButton(Icons.hd_rounded, 'HD', _showQualitySelector),
                                const SizedBox(width: 8),
                                _compactButton(Icons.dns_outlined, _manager.currentServer, _showServerSelector),
                                const SizedBox(width: 8),
                                _compactButton(
                                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                  '',
                                  _showVolumeSlider,
                                ),
                                 const SizedBox(width: 8),
                                 _compactButton(Icons.zoom_in_map_rounded, 'Zoom', _showZoomControls),
                                 const SizedBox(width: 8),
                                 _compactButton(Icons.settings_rounded, '', _showSettings),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeekBar() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
        thumbColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.15),
      ),
      child: Slider(
        value: _currentPosition.clamp(0.0, _totalDuration > 0 ? _totalDuration : 1.0),
        max: _totalDuration > 0 ? _totalDuration : 1.0,
        onChangeStart: (v) {
          _isSeeking = true;
        },
        onChanged: (v) {
          setState(() => _currentPosition = v);
        },
        onChangeEnd: (v) {
          _isSeeking = false;
          _seekTo(v);
        },
      ),
    );
  }

  String _shortenLanguageLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('latino') || lower.contains('mx') || lower.contains('419')) {
      return 'Latino';
    }
    if (lower.contains('castellano') || lower.contains('español') || lower.contains('espanol') || lower.contains('spanish') || lower == 'es') {
      return 'Español';
    }
    if (lower.contains('english') || lower.contains('inglés') || lower.contains('ingles') || lower == 'en') {
      return 'Inglés';
    }
    if (label.length > 10) {
      return '${label.substring(0, 8)}...';
    }
    return label;
  }

  String _formatDuration(double seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds < 0) return '0:00';
    final total = seconds.round();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _skipBackward() {
    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      final vpc = ctrl?.videoPlayerController;
      if (vpc == null) return;
      final pos = vpc.value.position;
      ctrl!.seekTo(Duration(milliseconds: (pos.inMilliseconds - 10000).clamp(0, 999999999)));
      return;
    }
    _webViewController?.runJavaScript('''
(function() {
  function findVideo(root) {
    root = root || document;
    var v = root.querySelector('video');
    if (v) return v;
    var iframes = root.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      try {
        var doc = iframes[i].contentDocument;
        if (doc) {
          v = doc.querySelector('video');
          if (v) return v;
        }
      } catch(e) {}
    }
    return null;
  }
  var v = findVideo();
  if (v) { v.currentTime = Math.max(0, v.currentTime - 10); }
  return 0;
})();
''');
  }

  void _skipForward() {
    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      final vpc = ctrl?.videoPlayerController;
      if (vpc == null) return;
      final pos = vpc.value.position;
      final dur = vpc.value.duration;
      ctrl!.seekTo(Duration(milliseconds: (pos.inMilliseconds + 10000).clamp(0, dur?.inMilliseconds ?? 0)));
      return;
    }
    _webViewController?.runJavaScript('''
(function() {
  function findVideo(root) {
    root = root || document;
    var v = root.querySelector('video');
    if (v) return v;
    var iframes = root.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      try {
        var doc = iframes[i].contentDocument;
        if (doc) {
          v = doc.querySelector('video');
          if (v) return v;
        }
      } catch(e) {}
    }
    return null;
  }
  var v = findVideo();
  if (v) { v.currentTime = Math.min(v.duration || 0, v.currentTime + 10); }
  return 0;
})();
''');
  }

  void _seekTo(double seconds) {
    if (_usingNativePlayer) {
      final ctrl = _betterPlayerController;
      if (ctrl == null) return;
      ctrl.seekTo(Duration(milliseconds: (seconds * 1000).round()));
      return;
    }
    _webViewController?.runJavaScript('''
(function() {
  function findVideo(root) {
    root = root || document;
    var v = root.querySelector('video');
    if (v) return v;
    var iframes = root.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      try {
        var doc = iframes[i].contentDocument;
        if (doc) {
          v = doc.querySelector('video');
          if (v) return v;
        }
      } catch(e) {}
    }
    return null;
  }
  var v = findVideo();
  if (v) { v.currentTime = $seconds; }
  return 0;
})();
''');
  }
}
