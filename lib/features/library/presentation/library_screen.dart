import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/library_provider.dart';
import '../data/custom_list_provider.dart';
import '../domain/custom_list_model.dart';
import '../domain/library_item.dart';
import 'list_detail_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';
import '../../../services/watch_history_service.dart';
import '../../../services/watch_history_model.dart';
import '../../../ui/library/custom_list_cover_widget.dart';
import '../../../ui/library/custom_list_privacy_badge.dart';



final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

String _translate(BuildContext context, String key) {
  final lang = Localizations.localeOf(context).languageCode;
  final Map<String, Map<String, String>> dict = {
    'es': {
      'history_tab': 'Historial',
      'make_private': 'Hacer privada',
      'make_public': 'Hacer pública',
      'public': 'Pública',
      'private': 'Privada',
      'public_desc': 'Visible para todos, puede recibir likes y comentarios',
      'private_desc': 'Solo visible para ti',
      'filter_all': 'Todas',
      'filter_likes': 'Me gusta',
      'filter_followed': 'Seguidas',
      'filter_personales': 'Personales',
      'no_lists_in_category': 'No hay listas en esta categoría',
      'empty_history': 'Sin historial de reproducción',
      'watch_history': 'Historial de reproducción',
      'items': 'elementos',
    },
    'en': {
      'history_tab': 'History',
      'make_private': 'Make private',
      'make_public': 'Make public',
      'public': 'Public',
      'private': 'Private',
      'public_desc': 'Visible to everyone, can receive likes and comments',
      'private_desc': 'Only visible to you',
      'filter_all': 'All',
      'filter_likes': 'Liked',
      'filter_followed': 'Followed',
      'filter_personales': 'Personal',
      'no_lists_in_category': 'No lists in this category',
      'empty_history': 'No watch history',
      'watch_history': 'Watch history',
      'items': 'items',
    },
    'pt': {
      'history_tab': 'Histórico',
      'make_private': 'Tornar privada',
      'make_public': 'Tornar pública',
      'public': 'Pública',
      'private': 'Privada',
      'public_desc': 'Visível para todos, pode receber curtidas e comentários',
      'private_desc': 'Visível apenas para você',
      'filter_all': 'Todas',
      'filter_likes': 'Curtidas',
      'filter_followed': 'Seguidas',
      'filter_personales': 'Pessoais',
      'no_lists_in_category': 'Nenhuma lista nesta categoria',
      'empty_history': 'Sem histórico de reprodução',
      'watch_history': 'Histórico de reprodução',
      'items': 'itens',
    },
    'it': {
      'history_tab': 'Cronologia',
      'make_private': 'Rendi privata',
      'make_public': 'Rendi pubblica',
      'public': 'Pubblica',
      'private': 'Privata',
      'public_desc': 'Visibile a tutti, può ricevere mi piace e commenti',
      'private_desc': 'Visibile solo a te',
      'filter_all': 'Tutte',
      'filter_likes': 'Mi piace',
      'filter_followed': 'Seguite',
      'filter_personales': 'Personali',
      'no_lists_in_category': 'Nessuna lista in questa categoria',
      'empty_history': 'Nessuna cronologia di riproduzione',
      'watch_history': 'Cronologia di riproduzione',
      'items': 'elementi',
    },
    'fr': {
      'history_tab': 'Historique',
      'make_private': 'Rendre privée',
      'make_public': 'Rendre publique',
      'public': 'Publique',
      'private': 'Privée',
      'public_desc': 'Visible par tous, peut recevoir des likes et des commentaires',
      'private_desc': 'Uniquement visible par vous',
      'filter_all': 'Toutes',
      'filter_likes': 'Likes',
      'filter_followed': 'Suivies',
      'filter_personales': 'Personnelles',
      'no_lists_in_category': 'Aucune liste dans cette catégorie',
      'empty_history': 'Aucun historique de lecture',
      'watch_history': 'Historique de lecture',
      'items': 'éléments',
    },
    'ru': {
      'history_tab': 'История',
      'make_private': 'Сделать приватным',
      'make_public': 'Сделать публичным',
      'public': 'Публичный',
      'private': 'Приватный',
      'public_desc': 'Виден всем, может получать лайки и комментарии',
      'private_desc': 'Видно только вам',
      'filter_all': 'Все',
      'filter_likes': 'Нравится',
      'filter_followed': 'Подписки',
      'filter_personales': 'Личные',
      'no_lists_in_category': 'Нет списков в этой категории',
      'empty_history': 'Нет истории воспроизведения',
      'watch_history': 'История воспроизведения',
      'items': 'эл.',
    },
    'ko': {
      'history_tab': '히스토리',
      'make_private': '비공개로 전환',
      'make_public': '공개로 전환',
      'public': '공개',
      'private': '비공개',
      'public_desc': '모두에게 표시되며 좋아요와 댓글을 받을 수 있습니다',
      'private_desc': '나에게만 표시',
      'filter_all': '전체',
      'filter_likes': '좋아요',
      'filter_followed': '팔로우됨',
      'filter_personales': '개인',
      'no_lists_in_category': '이 카테고리에 목록이 없습니다',
      'empty_history': '시청 기록 없음',
      'watch_history': '시청 기록',
      'items': '개',
    },
    'ja': {
      'history_tab': '履歴',
      'make_private': '非公開にする',
      'make_public': '公開にする',
      'public': '公開',
      'private': '非公開',
      'public_desc': '全員に公開され、いいねやコメントを受け取ることができます',
      'private_desc': 'あなただけに公開',
      'filter_all': 'すべて',
      'filter_likes': 'いいね',
      'filter_followed': 'フォロー中',
      'filter_personales': 'マイリスト',
      'no_lists_in_category': 'このカテゴリにはリストがありません',
      'empty_history': '視聴履歴はありません',
      'watch_history': '視聴履歴',
      'items': '項目',
    },
    'zh': {
      'history_tab': '历史',
      'make_private': '设为私有',
      'make_public': '设为公开',
      'public': '公开',
      'private': '私有',
      'public_desc': '对所有人可见，可以接收点赞 and 评论',
      'private_desc': '仅自己可见',
      'filter_all': '全部',
      'filter_likes': '点赞',
      'filter_followed': '关注',
      'filter_personales': '个人',
      'no_lists_in_category': '该类别下暂无列表',
      'empty_history': '暂无播放历史',
      'watch_history': '播放历史',
      'items': '项',
    }
  };
  return dict[lang]?[key] ?? dict['en']?[key] ?? key;
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      ref.read(_selectedCategoryProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myLibrary,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.watchLater),
            Tab(text: l10n.watched),
            Tab(text: l10n.favorites),
            Tab(text: l10n.customLists),
            Tab(text: _translate(context, 'history_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LibraryTab(
            asyncItems: ref.watch(watchLaterProvider),
            status: LibraryStatus.watchLater,
          ),
          _LibraryTab(
            asyncItems: ref.watch(watchedProvider),
            status: LibraryStatus.watched,
          ),
          _LibraryTab(
            asyncItems: ref.watch(favoritesProvider),
            status: 'favorites',
          ),
          _CustomListsTab(),
          _WatchHistoryTab(),
        ],
      ),
    );
  }
}

class _LibraryTab extends ConsumerWidget {
  final AsyncValue<List<LibraryItem>> asyncItems;
  final String status;

  const _LibraryTab({required this.asyncItems, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return asyncItems.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('${l10n.error}: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (allItems) {
        final filteredItems = selectedCategory == null
            ? allItems
            : allItems.where((i) => i.category == selectedCategory).toList();

        return Column(
          children: [
            _CategoryFilter(
              items: allItems,
              selectedCategory: selectedCategory,
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? _EmptyState(hasFilter: selectedCategory != null)
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) =>
                    _LibraryCard(item: filteredItems[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  final List<LibraryItem> items;
  final String? selectedCategory;

  const _CategoryFilter({required this.items, required this.selectedCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesInUse = items.map((i) => i.category).toSet().toList();
    if (categoriesInUse.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _FilterChip(
            label: l10n.all,
            selected: selectedCategory == null,
            onTap: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              ref.read(_selectedCategoryProvider.notifier).state = null;
            },
          ),
          ...categoriesInUse.map((cat) => _FilterChip(
            label: LibraryCategory.localizedLabel(cat, l10n),
            selected: selectedCategory == cat,
            onTap: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              ref.read(_selectedCategoryProvider.notifier).state = cat;
            },
          )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? null : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_outlined,
              size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            hasFilter ? l10n.noResults : l10n.nothingHere,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? l10n.tryOtherCategory
                : l10n.searchAndAdd,
            style: TextStyle(color: Theme.of(context).colorScheme.outlineVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
void _showCustomListOptions(BuildContext context, WidgetRef ref, CustomListModel list) {
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(list.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(l10n.edit, style: const TextStyle()),
            onTap: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx);
              _showEditListDialog(context, ref, list);
            },
          ),
          ListTile(
            leading: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: Text(l10n.share, style: const TextStyle()),
            onTap: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx);
              _shareCustomList(context, ref, list);
            },
          ),
          ListTile(
            leading: Icon(
              list.isPublic ? Icons.lock_open : Icons.lock,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(list.isPublic ? _translate(context, 'make_private') : _translate(context, 'make_public'), style: const TextStyle()),
            onTap: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx);
              ref.read(customListRepositoryProvider).setListVisibility(list.id, !list.isPublic);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            onTap: () async {
              final prefs = ref.read(soundPreferencesProvider);
              await SoundService.playRemove(prefs);
              if (!context.mounted) return;
              Navigator.pop(ctx);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(l10n.deleteListTitle, style: const TextStyle()),
                  content: Text(l10n.deleteListMessage(list.name), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  actions: [
                    TextButton(onPressed: () {
                      final prefs = ref.read(soundPreferencesProvider);
                      SoundService.playClick(prefs);
                      Navigator.pop(c, false);
                    }, child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber))),
                    TextButton(onPressed: () {
                      final prefs = ref.read(soundPreferencesProvider);
                      SoundService.playRemove(prefs);
                      Navigator.pop(c, true);
                    }, child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(customListRepositoryProvider).deleteList(list.id);
              }
            },
          ),
        ],
      ),
    ),
  );
}

void _showEditListDialog(BuildContext context, WidgetRef ref, CustomListModel list) {
  final l10n = AppLocalizations.of(context)!;
  final nameCtrl = TextEditingController(text: list.name);
  final descCtrl = TextEditingController(text: list.description);
  var isPublic = list.isPublic;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(l10n.editListTitle, style: const TextStyle()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: l10n.listName,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface,
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                hintText: l10n.listDescription,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface,
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: isPublic,
              onChanged: (v) => setDialogState(() => isPublic = v),
              title: Text(isPublic ? _translate(context, 'public') : _translate(context, 'private'), style: const TextStyle(fontSize: 14)),
              subtitle: Text(isPublic ? _translate(context, 'public_desc') : _translate(context, 'private_desc'), style: const TextStyle(fontSize: 11)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx);
            },
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playConfirm(prefs);
              ref.read(customListRepositoryProvider).updateList(list.copyWith(
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                isPublic: isPublic,
              ));
              Navigator.pop(ctx);
            },
            child: Text(l10n.save, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    ),
  );
}

void _shareCustomList(BuildContext context, WidgetRef ref, CustomListModel list) async {
  final l10n = AppLocalizations.of(context)!;
  final allItems = ref.read(libraryStreamProvider).valueOrNull ?? [];
  final items = allItems.where((i) => list.itemIds.contains(i.id)).toList();

  final header = '${l10n.shareList(list.name)}\n';
  final desc = list.description.isNotEmpty
      ? '${l10n.shareListDescription(items.length, list.description)}\n\n'
      : '';
  final itemList = items.isEmpty
      ? ''
      : '${l10n.shareListItems(list.name)}\n${items.map((i) {
          final url = 'https://www.themoviedb.org/${i.mediaType}/${i.tmdbId}';
          return 'â€¢ ${i.title} (${i.year}) - $url';
        }).join('\n')}';

  await Share.share('$header$desc$itemList');
}

class _CustomListsTab extends ConsumerStatefulWidget {
  @override
  _CustomListsTabState createState() => _CustomListsTabState();
}

class _CustomListsTabState extends ConsumerState<_CustomListsTab> {
  String _selectedFilter = 'todas';
  bool _isGridView = false;
  late SharedPreferences _prefs;
  bool _prefsInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFilter = _prefs.getString('lists_filter') ?? 'todas';
      _isGridView = _prefs.getBool('lists_view_mode') ?? false;
      _prefsInitialized = true;
    });
  }

  Future<void> _saveFilter(String filter) async {
    setState(() {
      _selectedFilter = filter;
    });
    if (_prefsInitialized) {
      await _prefs.setString('lists_filter', filter);
    }
  }

  Future<void> _saveViewMode(bool isGridView) async {
    setState(() {
      _isGridView = isGridView;
    });
    if (_prefsInitialized) {
      await _prefs.setBool('lists_view_mode', isGridView);
    }
  }

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    var isPublic = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.createListTitle, style: const TextStyle()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: l10n.listName,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface,
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  hintText: l10n.listDescription,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface,
                  border: const OutlineInputBorder(),
                ),
                style: const TextStyle(),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: isPublic,
                onChanged: (v) => setDialogState(() => isPublic = v),
                title: Text(isPublic ? _translate(context, 'public') : _translate(context, 'private'), style: const TextStyle(fontSize: 14)),
                subtitle: Text(isPublic ? _translate(context, 'public_desc') : _translate(context, 'private_desc'), style: const TextStyle(fontSize: 11)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playClick(prefs);
                Navigator.pop(ctx);
              },
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber))),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playConfirm(prefs);
                ref.read(customListRepositoryProvider).createList(nameCtrl.text.trim(), descCtrl.text.trim(), isPublic: isPublic);
                Navigator.pop(ctx);
              },
              child: Text(l10n.create, style: const TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listsAsync = ref.watch(customListsStreamProvider);
    final followedAsync = ref.watch(followedListsStreamProvider);
    final likedAsync = ref.watch(likedListsStreamProvider);

    if (listsAsync.isLoading && listsAsync.valueOrNull == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final lists = listsAsync.valueOrNull ?? [];
    final followed = followedAsync.valueOrNull ?? [];
    final liked = likedAsync.valueOrNull ?? [];

    final Map<String, CustomListModel> uniqueLists = {};
    for (final l in lists) {
      uniqueLists[l.id] = l;
    }
    for (final l in followed) {
      uniqueLists[l.id] = l;
    }
    for (final l in liked) {
      uniqueLists[l.id] = l;
    }
    final combined = uniqueLists.values.toList();
    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final filteredLists = combined.where((l) {
      if (_selectedFilter == 'likes') {
        return l.likedBy.contains(uid);
      } else if (_selectedFilter == 'followed') {
        return l.followedBy.contains(uid);
      } else if (_selectedFilter == 'personales') {
        return l.ownerUid == uid;
      }
      return true; // 'todas'
    }).toList();

    final countTodas = combined.length;
    final countLikes = combined.where((l) => l.likedBy.contains(uid)).length;
    final countFollowed = combined.where((l) => l.followedBy.contains(uid)).length;
    final countPersonales = combined.where((l) => l.ownerUid == uid).length;

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              _CustomListFilterChip(
                label: _translate(context, 'filter_all'),
                count: countTodas,
                selected: _selectedFilter == 'todas',
                onTap: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  _saveFilter('todas');
                },
              ),
              _CustomListFilterChip(
                label: _translate(context, 'filter_likes'),
                count: countLikes,
                selected: _selectedFilter == 'likes',
                onTap: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  _saveFilter('likes');
                },
              ),
              _CustomListFilterChip(
                label: _translate(context, 'filter_followed'),
                count: countFollowed,
                selected: _selectedFilter == 'followed',
                onTap: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  _saveFilter('followed');
                },
              ),
              _CustomListFilterChip(
                label: _translate(context, 'filter_personales'),
                count: countPersonales,
                selected: _selectedFilter == 'personales',
                onTap: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  _saveFilter('personales');
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final prefs = ref.read(soundPreferencesProvider);
                    SoundService.playClick(prefs);
                    _showCreateDialog(context);
                  },
                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  label: Text(l10n.createList, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  _saveViewMode(!_isGridView);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: child.key == const ValueKey('grid_icon')
                        ? Tween<double>(begin: 0.75, end: 1.0).animate(anim)
                        : Tween<double>(begin: 0.25, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _isGridView
                      ? const Icon(Icons.view_list, key: ValueKey('list_icon'))
                      : const Icon(Icons.grid_view, key: ValueKey('grid_icon')),
                ),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredLists.isEmpty
              ? Center(
                  child: Text(
                    _selectedFilter == 'todas'
                        ? l10n.createFirstList
                        : _translate(context, 'no_lists_in_category'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isGridView
                      ? GridView.builder(
                          key: const ValueKey('grid_view'),
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredLists.length,
                          itemBuilder: (_, i) => _CustomListGridCard(list: filteredLists[i]),
                        )
                      : ListView.builder(
                          key: const ValueKey('list_view'),
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90.0),
                          itemCount: filteredLists.length,
                          itemBuilder: (_, i) => _CustomListCard(list: filteredLists[i]),
                        ),
                ),
        ),
      ],
    );
  }
}

class _CustomListFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CustomListFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.brightness == Brightness.light
                  ? const Color(0xFFE8E8E8)
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomListGridCard extends ConsumerWidget {
  final CustomListModel list;
  const _CustomListGridCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final count = list.itemIds.length;

    return GestureDetector(
      onTap: () {
        final prefs = ref.read(soundPreferencesProvider);
        SoundService.playClick(prefs);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailScreen(list: list)));
      },
      onLongPress: () => _showCustomListOptions(context, ref, list),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
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
            Positioned(
              top: 8,
              right: 8,
              child: CustomListPrivacyBadge(isPublic: list.isPublic, small: true),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count ${_translate(context, 'items')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
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

class _CustomListCard extends ConsumerWidget {
  final CustomListModel list;
  const _CustomListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final prefs = ref.read(soundPreferencesProvider);
        SoundService.playClick(prefs);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailScreen(list: list)));
      },
      onLongPress: () => _showCustomListOptions(context, ref, list),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFE8E8E8)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomListCoverWidget(
              list: list,
              height: 48,
              width: 48,
              borderRadius: 10,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          list.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomListPrivacyBadge(isPublic: list.isPublic, small: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${list.itemIds.length} ${_translate(context, 'items')}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCard extends ConsumerWidget {
  final LibraryItem item;
  const _LibraryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        final prefs = ref.read(soundPreferencesProvider);
        SoundService.playClick(prefs);
        context.push('/detail/${item.tmdbId}?type=${item.mediaType}');
      },
      onLongPress: () => _showOptions(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFE8E8E8)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFE8E8E8)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.movie,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFE8E8E8)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.movie,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                ),
                if (item.isFavorite)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.amber, size: 14),
                    ),
                  ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.year.isNotEmpty ? "${item.year} " : ""}${LibraryCategory.localizedLabel(item.category, l10n)}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                if (item.rating != null)
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
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(libraryRepositoryProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              LibraryCategory.localizedLabel(item.category, l10n),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (item.status != LibraryStatus.watchLater)
              ListTile(
                leading: Icon(Icons.watch_later_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                title: Text(l10n.moveToWatchLater),
                onTap: () async {
                  final prefs = ref.read(soundPreferencesProvider);
                  await SoundService.playClick(prefs);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await repo.updateItem(item.copyWith(status: LibraryStatus.watchLater));
                },
              ),
            if (item.status != LibraryStatus.watched)
              ListTile(
                leading: Icon(Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                title: Text(l10n.markAsWatchedAction),
                onTap: () async {
                  final prefs = ref.read(soundPreferencesProvider);
                  await SoundService.playConfirm(prefs);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await repo.updateItem(item.copyWith(
                    status: LibraryStatus.watched,
                    watchedAt: DateTime.now(),
                  ));
                },
              ),
            ListTile(
              leading: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.amber,
              ),
              title: Text(item.isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites),
              onTap: () async {
                final prefs = ref.read(soundPreferencesProvider);
                await SoundService.playAdd(prefs);
                if (!context.mounted) return;
                Navigator.pop(context);
                await repo.updateItem(item.copyWith(isFavorite: !item.isFavorite));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(l10n.removeFromLibrary,
                  style: const TextStyle(color: Colors.red)),
              onTap: () async {
                final prefs = ref.read(soundPreferencesProvider);
                await SoundService.playRemove(prefs);
                if (!context.mounted) return;
                Navigator.pop(context);
                await repo.removeItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
final _watchHistoryProvider = StreamProvider<List<WatchHistoryEntry>>((ref) {
  return WatchHistoryService.watchAll();
});

class _WatchHistoryTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_WatchHistoryTab> createState() => _WatchHistoryTabState();
}

class _WatchHistoryTabState extends ConsumerState<_WatchHistoryTab> {
  bool _isGridView = false;
  late SharedPreferences _prefs;
  bool _prefsInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = _prefs.getBool('history_view_mode') ?? false;
      _prefsInitialized = true;
    });
  }

  Future<void> _saveViewMode(bool isGridView) async {
    setState(() {
      _isGridView = isGridView;
    });
    if (_prefsInitialized) {
      await _prefs.setBool('history_view_mode', isGridView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(_watchHistoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.error}: $e', style: const TextStyle(color: Colors.red))),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(_translate(context, 'empty_history'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _translate(context, 'watch_history'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  IconButton.outlined(
                    onPressed: () {
                      final prefs = ref.read(soundPreferencesProvider);
                      SoundService.playClick(prefs);
                      _saveViewMode(!_isGridView);
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isGridView
                          ? const Icon(Icons.list, key: ValueKey('list_icon'))
                          : const Icon(Icons.grid_view, key: ValueKey('grid_icon')),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTabletOrDesktop ? 4 : 3,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _WatchHistoryGridCard(entry: items[index]);
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final entry = items[i];
                        final pct = entry.percentage;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 50, height: 70,
                                child: entry.posterPath != null && entry.posterPath!.isNotEmpty
                                    ? Image.network('https://image.tmdb.org/t/p/w200${entry.posterPath}', fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.movie, size: 20)))
                                    : Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.movie, size: 20)),
                              ),
                            ),
                            title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.seasonEpisodeLabel.isNotEmpty)
                                  Text(entry.seasonEpisodeLabel, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(value: pct, minHeight: 3, backgroundColor: Colors.black12),
                                const SizedBox(height: 2),
                                Text('${(pct * 100).round()}%', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            ),
                            trailing: Text(
                              _formatDate(entry.lastWatched),
                              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            onTap: () {
                              final prefs = ref.read(soundPreferencesProvider);
                              SoundService.playClick(prefs);
                              context.push('/detail/${entry.tmdbId}?type=${entry.type}');
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

class _WatchHistoryGridCard extends ConsumerWidget {
  final WatchHistoryEntry entry;
  const _WatchHistoryGridCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final pct = entry.percentage;

    return GestureDetector(
      onTap: () {
        final prefs = ref.read(soundPreferencesProvider);
        SoundService.playClick(prefs);
        context.push('/detail/${entry.tmdbId}?type=${entry.type}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: cs.surfaceContainerHigh,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster Image
              entry.posterPath != null && entry.posterPath!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w300${entry.posterPath}',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: cs.surfaceContainerHighest),
                      errorWidget: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        child: const Icon(Icons.movie_outlined, size: 28),
                      ),
                    )
                  : Container(
                      color: cs.surfaceContainerHighest,
                      child: const Icon(Icons.movie_outlined, size: 28),
                    ),
              
              // Date Badge
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDate(entry.lastWatched),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Bottom Info Gradient Overlay
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.seasonEpisodeLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          entry.seasonEpisodeLabel,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
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
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
