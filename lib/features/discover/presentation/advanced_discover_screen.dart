import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/movie_poster.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/sound/sound_provider.dart';
import '../../search/domain/media_model.dart';
import '../data/discover_provider.dart';
import '../../../l10n/app_localizations.dart';

class AdvancedDiscoverScreen extends ConsumerStatefulWidget {
  const AdvancedDiscoverScreen({super.key});

  @override
  ConsumerState<AdvancedDiscoverScreen> createState() => _AdvancedDiscoverScreenState();
}

class _AdvancedDiscoverScreenState extends ConsumerState<AdvancedDiscoverScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Filter states
  String _mediaType = 'movie'; // 'movie' or 'tv'
  int? _selectedYear;
  String? _selectedRegion;
  final List<int> _selectedGenres = [];
  String _sortBy = 'popularity.desc';
  
  // Data lists
  List<Map<String, dynamic>> _genresList = [];
  final List<MediaModel> _items = [];
  
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  bool _showFilters = true;

  final List<int> _years = List.generate(47, (index) => 2026 - index); // 2026 down to 1980

  final Map<String, String> _regions = {
    'ES': 'España',
    'US': 'Estados Unidos',
    'MX': 'México',
    'AR': 'Argentina',
    'BR': 'Brasil',
    'FR': 'Francia',
    'IT': 'Italia',
    'GB': 'Reino Unido',
    'JP': 'Japón',
    'KR': 'Corea del Sur',
  };

  String _translate(String key, BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final Map<String, Map<String, String>> dict = {
      'es': {
        'title': 'Búsqueda Avanzada',
        'hide_filters': 'Ocultar Filtros',
        'show_filters': 'Mostrar Filtros',
        'movies': 'Películas',
        'tv_shows': 'Series',
        'year': 'Año',
        'any_year': 'Cualquier año',
        'country': 'País',
        'any_country': 'Cualquier país',
        'sort_by': 'Ordenar por',
        'most_popular': 'Más populares',
        'top_rated': 'Mejor calificación',
        'release_date': 'Fecha de estreno',
        'genres': 'Géneros',
        'no_results_filters': 'Intenta ajustar los filtros aplicados arriba.',
      },
      'en': {
        'title': 'Advanced Discover',
        'hide_filters': 'Hide Filters',
        'show_filters': 'Show Filters',
        'movies': 'Movies',
        'tv_shows': 'TV Shows',
        'year': 'Year',
        'any_year': 'Any Year',
        'country': 'Country',
        'any_country': 'Any Country',
        'sort_by': 'Sort By',
        'most_popular': 'Most Popular',
        'top_rated': 'Top Rated',
        'release_date': 'Release Date',
        'genres': 'Genres',
        'no_results_filters': 'Try adjusting the filters applied above.',
      },
      'pt': {
        'title': 'Busca Avançada',
        'hide_filters': 'Ocultar Filtros',
        'show_filters': 'Mostrar Filtros',
        'movies': 'Filmes',
        'tv_shows': 'Séries',
        'year': 'Ano',
        'any_year': 'Qualquer ano',
        'country': 'País',
        'any_country': 'Qualquer país',
        'sort_by': 'Ordenar por',
        'most_popular': 'Mais populares',
        'top_rated': 'Melhor avaliados',
        'release_date': 'Data de lançamento',
        'genres': 'Gêneros',
        'no_results_filters': 'Tente ajustar os filtros aplicados acima.',
      },
      'it': {
        'title': 'Ricerca Avanzata',
        'hide_filters': 'Nascondi Filtri',
        'show_filters': 'Mostra Filtri',
        'movies': 'Film',
        'tv_shows': 'Serie TV',
        'year': 'Anno',
        'any_year': 'Qualsiasi anno',
        'country': 'Paese',
        'any_country': 'Qualsiasi paese',
        'sort_by': 'Ordina per',
        'most_popular': 'Più popolari',
        'top_rated': 'Più votati',
        'release_date': 'Data di uscita',
        'genres': 'Generi',
        'no_results_filters': 'Prova a regolare i filtri applicati sopra.',
      },
      'fr': {
        'title': 'Recherche Avancée',
        'hide_filters': 'Masquer les filtres',
        'show_filters': 'Afficher les filtres',
        'movies': 'Films',
        'tv_shows': 'Séries TV',
        'year': 'Année',
        'any_year': 'Toutes les années',
        'country': 'Pays',
        'any_country': 'Tous les pays',
        'sort_by': 'Trier par',
        'most_popular': 'Plus populaires',
        'top_rated': 'Mieux notés',
        'release_date': 'Date de sortie',
        'genres': 'Genres',
        'no_results_filters': 'Essayez d\'ajuster les filtres appliqués ci-dessus.',
      },
      'ru': {
        'title': 'Расширенный поиск',
        'hide_filters': 'Скрыть фильтры',
        'show_filters': 'Показать фильтры',
        'movies': 'Фильмы',
        'tv_shows': 'Сериалы',
        'year': 'Год',
        'any_year': 'Любой год',
        'country': 'Страна',
        'any_country': 'Любая страна',
        'sort_by': 'Сортировать по',
        'most_popular': 'Популярные',
        'top_rated': 'Высокий рейтинг',
        'release_date': 'Дата релиза',
        'genres': 'Жанры',
        'no_results_filters': 'Попробуйте настроить фильтры, примененные выше.',
      },
      'ko': {
        'title': '고급 검색',
        'hide_filters': '필터 숨기기',
        'show_filters': '필터 보이기',
        'movies': '영화',
        'tv_shows': '시리즈',
        'year': '연도',
        'any_year': '모든 연도',
        'country': '국가',
        'any_country': '모든 국가',
        'sort_by': '정렬 기준',
        'most_popular': '인기순',
        'top_rated': '평점 높은순',
        'release_date': '출시일순',
        'genres': '장르',
        'no_results_filters': '위의 필터를 조정해 보세요.',
      },
      'ja': {
        'title': '詳細検索',
        'hide_filters': 'フィルターを非表示',
        'show_filters': 'フィルターを表示',
        'movies': '映画',
        'tv_shows': 'シリーズ',
        'year': '年',
        'any_year': 'すべての年',
        'country': '国',
        'any_country': 'すべての国',
        'sort_by': '並べ替え',
        'most_popular': '人気順',
        'top_rated': '評価順',
        'release_date': '公開日順',
        'genres': 'ジャンル',
        'no_results_filters': '上のフィルターを調整してみてください。',
      },
      'zh': {
        'title': '高级搜索',
        'hide_filters': '隐藏筛选',
        'show_filters': '显示筛选',
        'movies': '电影',
        'tv_shows': '电视剧',
        'year': '年份',
        'any_year': '所有年份',
        'country': '国家/地区',
        'any_country': '所有国家/地区',
        'sort_by': '排序方式',
        'most_popular': '最受欢迎',
        'top_rated': '评分最高',
        'release_date': '上映日期',
        'genres': '类型',
        'no_results_filters': '尝试调整上方应用的筛选条件。',
      }
    };
    return dict[lang]?[key] ?? dict['en']?[key] ?? key;
  }

  String _getRegionName(String code, BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final Map<String, Map<String, String>> translations = {
      'es': {
        'ES': 'España', 'US': 'Estados Unidos', 'MX': 'México', 'AR': 'Argentina', 'BR': 'Brasil',
        'FR': 'Francia', 'IT': 'Italia', 'GB': 'Reino Unido', 'JP': 'Japón', 'KR': 'Corea del Sur'
      },
      'en': {
        'ES': 'Spain', 'US': 'United States', 'MX': 'Mexico', 'AR': 'Argentina', 'BR': 'Brazil',
        'FR': 'France', 'IT': 'Italy', 'GB': 'United Kingdom', 'JP': 'Japan', 'KR': 'South Korea'
      },
      'pt': {
        'ES': 'Espanha', 'US': 'Estados Unidos', 'MX': 'México', 'AR': 'Argentina', 'BR': 'Brasil',
        'FR': 'França', 'IT': 'Itália', 'GB': 'Reino Unido', 'JP': 'Japão', 'KR': 'Coreia do Sul'
      },
      'it': {
        'ES': 'Spagna', 'US': 'Stati Uniti', 'MX': 'Messico', 'AR': 'Argentina', 'BR': 'Brasile',
        'FR': 'Francia', 'IT': 'Italia', 'GB': 'Regno Unito', 'JP': 'Giappone', 'KR': 'Corea del Sud'
      },
      'fr': {
        'ES': 'Espagne', 'US': 'États-Unis', 'MX': 'Mexique', 'AR': 'Argentine', 'BR': 'Brésil',
        'FR': 'France', 'IT': 'Italie', 'GB': 'Royaume-Uni', 'JP': 'Japon', 'KR': 'Corée du Sud'
      },
      'ru': {
        'ES': 'Испания', 'US': 'США', 'MX': 'Мексика', 'AR': 'Аргентина', 'BR': 'Бразилия',
        'FR': 'Франция', 'IT': 'Италия', 'GB': 'Великобритания', 'JP': 'Япония', 'KR': 'Южная Корея'
      },
      'ko': {
        'ES': '스페인', 'US': '미국', 'MX': '멕시코', 'AR': '아르헨티나', 'BR': '브라질',
        'FR': '프랑스', 'IT': '이탈리아', 'GB': '영국', 'JP': '일본', 'KR': '대한민국'
      },
      'ja': {
        'ES': 'スペイン', 'US': 'アメリカ', 'MX': 'メキシコ', 'AR': 'アルゼンチン', 'BR': 'ブラジル',
        'FR': 'フランス', 'IT': 'イタリア', 'GB': 'イギリス', 'JP': '日本', 'KR': '韓国'
      },
      'zh': {
        'ES': '西班牙', 'US': '美国', 'MX': '墨西哥', 'AR': '阿根廷', 'BR': '巴西',
        'FR': '法国', 'IT': '意大利', 'GB': '英国', 'JP': '日本', 'KR': '韩国'
      }
    };
    return translations[lang]?[code] ?? translations['en']?[code] ?? code;
  }

  @override
  void initState() {
    super.initState();
    _loadGenresAndSearch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  Future<void> _loadGenresAndSearch() async {
    setState(() {
      _isLoading = true;
      _items.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });

    try {
      final api = ref.read(tmdbApiProvider);
      List<Map<String, dynamic>> genres = [];
      if (_mediaType == 'movie') {
        genres = await api.getMovieGenres();
      } else {
        genres = await api.getTvGenres();
      }
      
      if (mounted) {
        setState(() {
          _genresList = genres;
        });
        await _fetchNextPage();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading && _items.isNotEmpty) return;
    if (!_hasMore) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(tmdbApiProvider);
      final raw = await api.discoverMedia(
        type: _mediaType,
        page: _page,
        year: _selectedYear,
        region: _selectedRegion,
        genres: _selectedGenres.isEmpty ? null : _selectedGenres,
        sortBy: _sortBy,
      );

      final fetched = raw.map((json) {
        final map = Map<String, dynamic>.from(json);
        if (!map.containsKey('media_type')) {
          map['media_type'] = _mediaType;
        }
        return MediaModel.fromJson(map);
      }).toList();

      if (mounted) {
        setState(() {
          _items.addAll(fetched);
          _page++;
          _isLoading = false;
          if (fetched.isEmpty || fetched.length < 20) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _resetSearch() {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    _fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTabletOrDesktop = MediaQuery.of(context).size.width > 600;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final fieldFillColor = isLight ? const Color(0xFFE8E8E8) : cs.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('title', context), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? _translate('hide_filters', context) : _translate('show_filters', context),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showFilters ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Media Type Filter SegmentedButton
                      Expanded(
                        child: SegmentedButton<String>(
                          style: SegmentedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          segments: [
                            ButtonSegment(value: 'movie', label: Text(_translate('movies', context), style: const TextStyle(fontSize: 12)), icon: const Icon(Icons.movie, size: 16)),
                            ButtonSegment(value: 'tv', label: Text(_translate('tv_shows', context), style: const TextStyle(fontSize: 12)), icon: const Icon(Icons.tv, size: 16)),
                          ],
                          selected: {_mediaType},
                          onSelectionChanged: (val) {
                            final prefs = ref.read(soundPreferencesProvider);
                            SoundService.playClick(prefs);
                            setState(() {
                              _mediaType = val.first;
                              _selectedGenres.clear();
                            });
                            _loadGenresAndSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Year selector
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedYear,
                          decoration: InputDecoration(
                            labelText: _translate('year', context),
                            labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                            filled: true,
                            fillColor: fieldFillColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          dropdownColor: fieldFillColor,
                          items: [
                            DropdownMenuItem(value: null, child: Text(_translate('any_year', context), style: const TextStyle(fontSize: 13))),
                            ..._years.map((y) => DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontSize: 13)))),
                          ],
                          onChanged: (val) {
                            final prefs = ref.read(soundPreferencesProvider);
                            SoundService.playClick(prefs);
                            setState(() => _selectedYear = val);
                            _resetSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Country / Region selector
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedRegion,
                          decoration: InputDecoration(
                            labelText: _translate('country', context),
                            labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                            filled: true,
                            fillColor: fieldFillColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          dropdownColor: fieldFillColor,
                          items: [
                            DropdownMenuItem(value: null, child: Text(_translate('any_country', context), style: const TextStyle(fontSize: 13))),
                            ..._regions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(_getRegionName(e.key, context), style: const TextStyle(fontSize: 13)))),
                          ],
                          onChanged: (val) {
                            final prefs = ref.read(soundPreferencesProvider);
                            SoundService.playClick(prefs);
                            setState(() => _selectedRegion = val);
                            _resetSearch();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Sort By Selector
                  DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: InputDecoration(
                      labelText: _translate('sort_by', context),
                      labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                      filled: true,
                      fillColor: fieldFillColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    dropdownColor: fieldFillColor,
                    items: [
                      DropdownMenuItem(value: 'popularity.desc', child: Text(_translate('most_popular', context), style: const TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'vote_average.desc', child: Text(_translate('top_rated', context), style: const TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'primary_release_date.desc', child: Text(_translate('release_date', context), style: const TextStyle(fontSize: 13))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        final prefs = ref.read(soundPreferencesProvider);
                        SoundService.playClick(prefs);
                        setState(() => _sortBy = val);
                        _resetSearch();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  // Genres horizontal list
                  Text(_translate('genres', context), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _genresList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final g = _genresList[i];
                        final id = g['id'] as int;
                        final name = g['name'] as String;
                        final isSelected = _selectedGenres.contains(id);
                        return FilterChip(
                          label: Text(name, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          onSelected: (selected) {
                            final prefs = ref.read(soundPreferencesProvider);
                            SoundService.playClick(prefs);
                            setState(() {
                              if (selected) {
                                _selectedGenres.add(id);
                              } else {
                                _selectedGenres.remove(id);
                              }
                            });
                            _resetSearch();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _items.isEmpty && _isLoading
                ? _buildShimmerGrid(isTabletOrDesktop)
                : _error != null && _items.isEmpty
                    ? _buildErrorView()
                    : _items.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isTabletOrDesktop ? 4 : 3,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    return _GridCard(item: _items[index]);
                                  },
                                ),
                              ),
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid(bool isTabletOrDesktop) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTabletOrDesktop ? 4 : 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 15,
      itemBuilder: (_, __) => const ShimmerLoading(width: 120, height: 180),
    );
  }

  Widget _buildErrorView() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '${l10n.errorLoading}:\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetSearch,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsSearch,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _translate('no_results_filters', context),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends ConsumerStatefulWidget {
  final MediaModel item;
  const _GridCard({required this.item});

  @override
  ConsumerState<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends ConsumerState<_GridCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playClick(prefs);
        if (context.mounted) {
          context.push('/detail/${item.id}?type=${item.mediaType}');
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MoviePoster(
                  imageUrl: item.posterPath.isNotEmpty
                      ? 'https://image.tmdb.org/t/p/w300${item.posterPath}'
                      : null,
                  useHero: false,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.releaseDate.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.releaseDate.split('-').first,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (item.voteAverage > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            item.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
