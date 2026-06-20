import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/custom_list_model.dart';
import '../data/custom_list_provider.dart';
import 'list_detail_screen.dart';
import '../../../ui/library/custom_list_cover_widget.dart';
import '../../../ui/library/custom_list_privacy_badge.dart';
import '../../../l10n/app_localizations.dart';

enum ListSortMode {
  recientes,
  populares,
  seguidas,
  alfabetico,
}

class PublicListsScreen extends ConsumerStatefulWidget {
  const PublicListsScreen({super.key});

  @override
  ConsumerState<PublicListsScreen> createState() => _PublicListsScreenState();
}

class _PublicListsScreenState extends ConsumerState<PublicListsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  ListSortMode _sortMode = ListSortMode.recientes;
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = prefs.getBool('public_lists_view_mode') ?? false;
    });
  }

  Future<void> _saveViewMode(bool value) async {
    setState(() => _isGridView = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('public_lists_view_mode', value);
  }

  String _translate(String key, BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final Map<String, Map<String, String>> dict = {
      'es': {
        'title': 'Listas Públicas',
        'search_hint': 'Buscar listas...',
        'recent': 'Recientes',
        'popular': 'Populares',
        'most_followed': 'Más Seguidas',
        'alphabetical': 'Alfabético',
        'error_loading': 'Error al cargar las listas',
        'no_results_search': 'No se encontraron listas para tu búsqueda',
        'no_public_lists': 'No hay listas públicas todavía',
        'db_configuring': 'Configurando base de datos. Por favor, reintente en unos momentos.',
      },
      'en': {
        'title': 'Public Lists',
        'search_hint': 'Search lists...',
        'recent': 'Recent',
        'popular': 'Popular',
        'most_followed': 'Most Followed',
        'alphabetical': 'Alphabetical',
        'error_loading': 'Error loading lists',
        'no_results_search': 'No lists found for your search',
        'no_public_lists': 'No public lists yet',
        'db_configuring': 'Configuring database index. Please retry in a few moments.',
      },
      'pt': {
        'title': 'Listas Públicas',
        'search_hint': 'Buscar listas...',
        'recent': 'Recentes',
        'popular': 'Populares',
        'most_followed': 'Mais Seguidas',
        'alphabetical': 'Alfabético',
        'error_loading': 'Erro ao carregar as listas',
        'no_results_search': 'Nenhuma lista encontrada para sua busca',
        'no_public_lists': 'Ainda não há listas públicas',
        'db_configuring': 'Configurando o banco de dados. Por favor, tente novamente em instantes.',
      },
      'it': {
        'title': 'Liste Pubbliche',
        'search_hint': 'Cerca liste...',
        'recent': 'Recenti',
        'popular': 'Popolari',
        'most_followed': 'Più Seguite',
        'alphabetical': 'Alfabetico',
        'error_loading': 'Errore durante il caricamento delle liste',
        'no_results_search': 'Nessuna lista trovata per la tua ricerca',
        'no_public_lists': 'Non ci sono ancora liste pubbliche',
        'db_configuring': 'Configurazione del database in corso. Riprova tra pochi istanti.',
      },
      'fr': {
        'title': 'Listes Publiques',
        'search_hint': 'Rechercher des listes...',
        'recent': 'Récentes',
        'popular': 'Populaires',
        'most_followed': 'Plus Suivies',
        'alphabetical': 'Alphabétique',
        'error_loading': 'Erreur lors du chargement des listes',
        'no_results_search': 'Aucune liste trouvée pour votre recherche',
        'no_public_lists': 'Pas encore de listes publiques',
        'db_configuring': 'Configuration de la base de données. Veuillez réessayer dans quelques instants.',
      },
      'ru': {
        'title': 'Публичные списки',
        'search_hint': 'Поиск списков...',
        'recent': 'Недавние',
        'popular': 'Популярные',
        'most_followed': 'Популярные подписки',
        'alphabetical': 'По алфавиту',
        'error_loading': 'Ошибка загрузки списков',
        'no_results_search': 'Списки по вашему запросу не найдены',
        'no_public_lists': 'Публичных списков пока нет',
        'db_configuring': 'Настройка базы данных. Пожалуйста, повторите попытку позже.',
      },
      'ko': {
        'title': '공개 목록',
        'search_hint': '목록 검색...',
        'recent': '최신순',
        'popular': '인기순',
        'most_followed': '가장 많이 팔로우됨',
        'alphabetical': '가나다순',
        'error_loading': '목록을 불러오는 중 오류 발생',
        'no_results_search': '검색 결과에 맞는 목록이 없습니다',
        'no_public_lists': '아직 공개 목록이 없습니다',
        'db_configuring': '데이터베이스 설정 중입니다. 잠시 후 다시 시도해 주세요.',
      },
      'ja': {
        'title': '公開リスト',
        'search_hint': 'リストを検索...',
        'recent': '最新順',
        'popular': '人気順',
        'most_followed': 'お気に入り順',
        'alphabetical': '名前順',
        'error_loading': 'リストの読み込みに失敗しました',
        'no_results_search': '検索条件に一致するリストが見つかりませんでした',
        'no_public_lists': '公開リストはまだありません',
        'db_configuring': 'データベースを設定しています。しばらくしてからもう一度お試しください。',
      },
      'zh': {
        'title': '公开列表',
        'search_hint': '搜索列表...',
        'recent': '最近',
        'popular': '热门',
        'most_followed': '最受关注',
        'alphabetical': '字母顺序',
        'error_loading': '加载列表时出错',
        'no_results_search': '未找到符合搜索条件的列表',
        'no_public_lists': '暂无公开列表',
        'db_configuring': '正在配置数据库索引。请稍后再试。',
      }
    };
    return dict[lang]?[key] ?? dict['en']?[key] ?? key;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }


  void _openIndexUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[PublicLists] Failed to open index URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicListsAsync = ref.watch(publicListsStreamProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('title', context), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Sort controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: _translate('search_hint', context),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchCtrl.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ListSortMode>(
                      value: _sortMode,
                      icon: Icon(Icons.sort, color: cs.primary),
                      dropdownColor: cs.surfaceContainerHighest,
                      items: [
                        DropdownMenuItem(
                          value: ListSortMode.recientes,
                          child: Text(_translate('recent', context), style: const TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: ListSortMode.populares,
                          child: Text(_translate('popular', context), style: const TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: ListSortMode.seguidas,
                          child: Text(_translate('most_followed', context), style: const TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: ListSortMode.alfabetico,
                          child: Text(_translate('alphabetical', context), style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          setState(() {
                            _sortMode = mode;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () => _saveViewMode(!_isGridView),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: child.key == const ValueKey('grid')
                          ? Tween<double>(begin: 0.75, end: 1.0).animate(anim)
                          : Tween<double>(begin: 0.25, end: 1.0).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: _isGridView
                        ? const Icon(Icons.view_list, key: ValueKey('list'))
                        : const Icon(Icons.grid_view, key: ValueKey('grid')),
                  ),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: publicListsAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (_, __) => const _SkeletonListCard(),
              ),
              error: (err, _) {
                final isIndexError = err.toString().contains('failed-precondition') || err.toString().contains('index');
                String? indexUrl;
                if (err is FirebaseException && err.plugin == 'firestore') {
                  final body = err.message ?? '';
                  final urlMatch = RegExp('https://console\\.firebase\\.google\\.com[^\\s<>]+').firstMatch(body);
                  if (urlMatch != null) {
                    indexUrl = urlMatch.group(0);
                  }
                }
                final isConfiguring = isIndexError && indexUrl == null;

                final List<Widget> errorChildren = [];
                errorChildren.add(
                  Icon(isIndexError ? Icons.settings : Icons.error_outline, size: 48, color: isIndexError ? cs.primary : Colors.red),
                );
                errorChildren.add(const SizedBox(height: 16));
                errorChildren.add(
                  Text(
                    isIndexError && !isConfiguring
                        ? 'Public lists are temporarily unavailable while the database index is being configured.'
                        : isConfiguring
                            ? _translate('db_configuring', context)
                            : '${_translate('error_loading', context)}: $err',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                  ),
                );
                if (isIndexError && !isConfiguring) {
                  errorChildren.add(const SizedBox(height: 16));
                  errorChildren.add(
                    Text(
                      'Check Firebase Console or click below to create the missing index.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  );
                  if (indexUrl != null) {
                    errorChildren.add(const SizedBox(height: 12));
                    errorChildren.add(
                      FilledButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Create Index'),
                        onPressed: () => _openIndexUrl(indexUrl!),
                      ),
                    );
                  }
                }
                errorChildren.add(const SizedBox(height: 16));
                errorChildren.add(
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(publicListsStreamProvider);
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                );

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: errorChildren,
                    ),
                  ),
                );
              },
              data: (lists) {
                // Filter
                var filtered = lists;
                if (_searchQuery.isNotEmpty) {
                  filtered = lists.where((l) {
                    return l.name.toLowerCase().contains(_searchQuery) ||
                        l.description.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                // Sort
                switch (_sortMode) {
                  case ListSortMode.recientes:
                    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    break;
                  case ListSortMode.populares:
                    filtered.sort((a, b) => b.likeCount.compareTo(a.likeCount));
                    break;
                  case ListSortMode.seguidas:
                    filtered.sort((a, b) => b.followedBy.length.compareTo(a.followedBy.length));
                    break;
                  case ListSortMode.alfabetico:
                    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    break;
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers_clear_outlined, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? _translate('no_results_search', context)
                              : _translate('no_public_lists', context),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Si tienes listas públicas pero no aparecen, despliega los índices de Firestore:\n'
                            'firebase deploy --only firestore:indexes',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isGridView
                      ? GridView.builder(
                          key: const ValueKey('grid'),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTabletOrDesktop ? 3 : 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _PublicListGridCard(list: filtered[index]);
                          },
                        )
                      : GridView.builder(
                          key: const ValueKey('list'),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTabletOrDesktop ? 2 : 1,
                            mainAxisExtent: 200,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final list = filtered[index];
                            return _PublicListCard(list: list);
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicListCard extends ConsumerWidget {
  final CustomListModel list;
  const _PublicListCard({required this.list});

  void _shareList(BuildContext context) {
    final name = list.name;
    final desc = list.description.isNotEmpty ? '${list.description}\n\n' : '';
    final url = 'https://moviememory.app/list/${list.ownerUid}/${list.id}';
    Share.share('¡Mira esta lista en MovieMemory! 🎉\n$name\n$desc Enlace: $url');
  }

  void _copyLink(BuildContext context) {
    final url = 'https://moviememory.app/list/${list.ownerUid}/${list.id}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final authorAsync = ref.watch(userProfileProvider(list.ownerUid));
    final isFollowing = list.followedBy.contains(currentUid);
    final formattedDate = DateFormat('dd/MM/yyyy').format(list.createdAt);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListDetailScreen(list: list),
            ),
          );
        },
        child: Row(
          children: [
            // List Cover Image
            CustomListCoverWidget(
              list: list,
              height: double.infinity,
              width: 130,
              borderRadius: 0,
            ),
            
            // List Info Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            list.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomListPrivacyBadge(isPublic: list.isPublic, small: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      list.description.isNotEmpty ? list.description : 'Sin descripción',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Author
                    authorAsync.when(
                      data: (user) => Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundImage: user?.photoURL.isNotEmpty == true
                                ? CachedNetworkImageProvider(user!.photoURL)
                                : null,
                            child: user?.photoURL.isEmpty == true
                                ? const Icon(Icons.person, size: 8)
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user != null ? '${user.firstName} ${user.lastName}' : 'Usuario',
                              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                      error: (_, __) => Text('Usuario', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    ),
                    const Spacer(),
                    
                    // Stats and Metadata
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.movie_outlined, size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${list.itemIds.length}', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                          const SizedBox(width: 10),
                          Icon(Icons.favorite_border, size: 11, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${list.likeCount}', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                          const SizedBox(width: 10),
                          Icon(Icons.people_outline, size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${list.followedBy.length}', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                          const SizedBox(width: 10),
                          Icon(Icons.calendar_today_outlined, size: 11, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(formattedDate, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _shareList(context),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.link_outlined, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _copyLink(context),
                        ),
                        const SizedBox(width: 12),
                        if (list.ownerUid != currentUid)
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100, minWidth: 70),
                              child: SizedBox(
                                height: 26,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFollowing ? cs.surfaceContainerHigh : cs.primary,
                                    foregroundColor: isFollowing ? cs.onSurface : cs.onPrimary,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    ref.read(customListRepositoryProvider).toggleFollow(list.id, list.ownerUid);
                                  },
                                  child: Text(
                                    isFollowing ? l10n.following : l10n.follow,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
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
          ],
        ),
      ),
    );
  }
}

class _SkeletonListCard extends StatefulWidget {
  const _SkeletonListCard();

  @override
  State<_SkeletonListCard> createState() => _SkeletonListCardState();
}

class _SkeletonListCardState extends State<_SkeletonListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + 0.4 * _anim.value,
          child: child,
        );
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 130,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: cs.surfaceContainerHigh),
                    const SizedBox(height: 6),
                    Container(width: 180, height: 12, color: cs.surfaceContainerHigh),
                    const SizedBox(height: 4),
                    Container(width: 140, height: 12, color: cs.surfaceContainerHigh),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 14, color: cs.surfaceContainerHigh),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(width: 24, height: 24, color: cs.surfaceContainerHigh),
                        const SizedBox(width: 12),
                        Container(width: 24, height: 24, color: cs.surfaceContainerHigh),
                        const SizedBox(width: 12),
                        Container(width: 60, height: 24, color: cs.surfaceContainerHigh),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicListGridCard extends ConsumerWidget {
  final CustomListModel list;
  const _PublicListGridCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isFollowing = list.followedBy.contains(currentUid);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListDetailScreen(list: list)),
        );
      },
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomListCoverWidget(
              list: list,
              height: double.infinity,
              width: double.infinity,
              borderRadius: 0,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CustomListPrivacyBadge(isPublic: list.isPublic, small: true),
            ),
            if (isFollowing)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 10),
                      SizedBox(width: 2),
                      Text(
                        'Siguiendo',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.movie_outlined, color: Colors.white70, size: 11),
                        const SizedBox(width: 3),
                        Text('${list.itemIds.length}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite_border, color: Colors.white70, size: 10),
                        const SizedBox(width: 3),
                        Text('${list.likeCount}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(width: 8),
                        const Icon(Icons.people_outline, color: Colors.white70, size: 11),
                        const SizedBox(width: 3),
                        Text('${list.followedBy.length}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
