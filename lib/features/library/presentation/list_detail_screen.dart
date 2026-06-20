import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';
import '../data/library_provider.dart';
import '../data/custom_list_provider.dart';
import '../data/list_comment_service.dart';
import '../data/list_comment_provider.dart';
import '../domain/list_comment_model.dart';
import '../domain/custom_list_model.dart';
import '../domain/library_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../discover/data/discover_provider.dart';
import '../../search/domain/media_model.dart';
import '../../../ui/library/custom_list_cover_widget.dart';
import '../../../ui/library/custom_list_privacy_badge.dart';
import '../../../shared/comment_utils.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  final CustomListModel list;
  const ListDetailScreen({super.key, required this.list});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  late CustomListModel _list;
  bool _isLoadingCover = false;
  StreamSubscription<DocumentSnapshot>? _listSubscription;

  @override
  void initState() {
    super.initState();
    _list = widget.list;
    _subscribeToList();
  }

  void _subscribeToList() {
    final ownerUid = _list.ownerUid.isEmpty
        ? (FirebaseAuth.instance.currentUser?.uid ?? '')
        : _list.ownerUid;
    if (ownerUid.isNotEmpty && _list.id.isNotEmpty) {
      _listSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(ownerUid)
          .collection('customLists')
          .doc(_list.id)
          .snapshots()
          .listen((doc) {
        if (doc.exists && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _list = CustomListModel.fromMap(doc.id, doc.data()!, ownerUid: ownerUid);
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _listSubscription?.cancel();
    super.dispose();
  }

  Future<void> _removeCoverImage() async {
    setState(() => _isLoadingCover = true);
    try {
      await ref.read(customListRepositoryProvider).removeListCover(_list.id);
      setState(() {
        _list = _list.copyWith(coverUrl: null);
        _isLoadingCover = false;
      });
    } catch (e) {
      setState(() => _isLoadingCover = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar la portada: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showUrlCoverInputDialog() {
    final controller = TextEditingController(
      text: _list.coverUrl ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL de portada de lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://ejemplo.com/portada.jpg',
            helperText: 'Debe ser una dirección web válida',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              final uri = Uri.tryParse(url);
              final isUrl = uri != null && uri.hasAbsolutePath;
              if (!isUrl) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('URL no válida. Debe comenzar con http:// o https://'),
                  backgroundColor: Colors.red,
                ));
                return;
              }
              final path = uri.path.toLowerCase();
              final isImage = path.endsWith('.jpg') ||
                  path.endsWith('.jpeg') ||
                  path.endsWith('.png') ||
                  path.endsWith('.gif') ||
                  path.endsWith('.webp') ||
                  path.endsWith('.bmp') ||
                  url.contains('picsum.photos') ||
                  url.contains('placeholder');
              if (!isImage) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('La URL debe apuntar a una imagen válida (.jpg, .jpeg, .png, .webp, .gif)'),
                  backgroundColor: Colors.red,
                ));
                return;
              }
              
              Navigator.pop(ctx);
              setState(() => _isLoadingCover = true);
              try {
                await ref.read(customListRepositoryProvider).updateList(_list.copyWith(coverUrl: url));
                setState(() {
                  _list = _list.copyWith(coverUrl: url);
                  _isLoadingCover = false;
                });
              } catch (e) {
                setState(() => _isLoadingCover = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error al guardar la portada: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showCoverOptions() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerHighest,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link_outlined),
                title: const Text('Introducir URL de portada'),
                onTap: () {
                  Navigator.pop(context);
                  _showUrlCoverInputDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text('Composición: Grid de películas'),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _isLoadingCover = true);
                  try {
                    await ref.read(customListRepositoryProvider).updateList(_list.copyWith(coverUrl: 'auto_grid'));
                    setState(() {
                      _list = _list.copyWith(coverUrl: 'auto_grid');
                      _isLoadingCover = false;
                    });
                  } catch (e) {
                    setState(() => _isLoadingCover = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error al configurar portada de grid: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                },
              ),
              if (_list.coverUrl != null && _list.coverUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Eliminar portada', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeCoverImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverBanner(bool isOwner, ColorScheme cs) {
    return GestureDetector(
      onTap: (isOwner && !_isLoadingCover) ? _showCoverOptions : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomListCoverWidget(
            list: _list,
            height: 180,
            width: double.infinity,
            borderRadius: 0,
          ),
          if (_isLoadingCover)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          if (isOwner && !_isLoadingCover)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editList() async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: _list.name);
    final descCtrl = TextEditingController(text: _list.description);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editList, style: const TextStyle()),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx, false);
            },
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playConfirm(prefs);
              Navigator.pop(ctx, true);
            },
            child: Text(l10n.save, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (result == true) {
      final repo = ref.read(customListRepositoryProvider);
      await repo.updateList(_list.copyWith(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
      ));
      setState(() {
        _list = _list.copyWith(
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim(),
        );
      });
    }
  }

  Future<void> _deleteList() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteListTitle, style: const TextStyle()),
        content: Text(l10n.deleteListMessage(_list.name), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () {
            final prefs = ref.read(soundPreferencesProvider);
            SoundService.playClick(prefs);
            Navigator.pop(ctx, false);
          }, child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber))),
          TextButton(onPressed: () {
            final prefs = ref.read(soundPreferencesProvider);
            SoundService.playRemove(prefs);
            Navigator.pop(ctx, true);
          }, child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(customListRepositoryProvider).deleteList(_list.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _removeItem(LibraryItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playRemove(prefs);
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteItemTitle, style: const TextStyle()),
        content: Text(l10n.deleteItemMessage(item.title), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () {
            final prefs = ref.read(soundPreferencesProvider);
            SoundService.playClick(prefs);
            Navigator.pop(ctx, false);
          }, child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber))),
          TextButton(onPressed: () {
            final prefs = ref.read(soundPreferencesProvider);
            SoundService.playRemove(prefs);
            Navigator.pop(ctx, true);
          }, child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(customListRepositoryProvider);
      await repo.removeItemFromList(_list.id, item.id);
    }
  }

  Future<void> _addItem() async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.addToListTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
                leading: Icon(Icons.library_books, color: Theme.of(context).colorScheme.primary, size: 28),
                title: const Text('Desde mi librería', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Seleccionar de tu librería multimedia', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                onTap: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  Navigator.pop(ctx, 'library');
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
                leading: Icon(Icons.search, color: Theme.of(context).colorScheme.primary, size: 28),
                title: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Buscar contenido nuevo para agregar', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                onTap: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  Navigator.pop(ctx, 'search');
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == 'library') {
      await _showLibraryPicker();
    } else if (choice == 'search') {
      await _showSearchPicker();
    }
  }

  Future<void> _showLibraryPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final allItems = ref.read(libraryStreamProvider).valueOrNull ?? [];
    final repo = ref.read(customListRepositoryProvider);

    if (allItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orange,
          content: Text(l10n.noItemsInList),
        ));
      }
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final selectedItemIds = Set<String>.from(_list.itemIds);
        return StatefulBuilder(
          builder: (ctx, setSheetState) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.addToListTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: allItems.length,
                    itemBuilder: (_, i) {
                      final item = allItems[i];
                      final isSelected = selectedItemIds.contains(item.id);
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 40, height: 60,
                            child: item.posterUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: item.posterUrl, fit: BoxFit.cover)
                                : Container(color: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface, child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20)),
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(item.year, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        trailing: Checkbox(
                          value: isSelected,
                          activeColor: Theme.of(context).colorScheme.primary,
                          checkColor: Colors.white,
                          onChanged: (_) {
                            final prefs = ref.read(soundPreferencesProvider);
                            SoundService.playClick(prefs);
                            setSheetState(() {
                              if (isSelected) {
                                selectedItemIds.remove(item.id);
                              } else {
                                selectedItemIds.add(item.id);
                              }
                            });
                            if (isSelected) {
                              repo.removeItemFromList(_list.id, item.id);
                            } else {
                              repo.addItemToList(_list.id, item.id);
                            }
                          },
                        ),
                        onTap: () {
                          final prefs = ref.read(soundPreferencesProvider);
                          SoundService.playClick(prefs);
                          setSheetState(() {
                            if (isSelected) {
                              selectedItemIds.remove(item.id);
                            } else {
                              selectedItemIds.add(item.id);
                            }
                          });
                          if (isSelected) {
                            repo.removeItemFromList(_list.id, item.id);
                          } else {
                            repo.addItemToList(_list.id, item.id);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSearchPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final searchController = TextEditingController();
    final api = ref.read(tmdbApiProvider);
    final libRepo = ref.read(libraryRepositoryProvider);
    final listRepo = ref.read(customListRepositoryProvider);
    Timer? debounce;
    bool searchDismissed = false;
    bool showSuccessSnackBar = false;
    List<MediaModel> results = [];
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                onPressed: () {
                                  final prefs = ref.read(soundPreferencesProvider);
                                  SoundService.playClick(prefs);
                                  searchController.clear();
                                  setSheetState(() {
                                    results = [];
                                    isLoading = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        debounce?.cancel();
                        if (value.trim().isEmpty) {
                          setSheetState(() {
                            results = [];
                            isLoading = false;
                          });
                          return;
                        }
                        setSheetState(() => isLoading = true);
                        debounce = Timer(const Duration(milliseconds: 400), () async {
                          if (searchDismissed) return;
                          try {
                            final data = await api.searchMulti(value.trim());
                            if (!searchDismissed && ctx.mounted) {
                              setSheetState(() {
                                results = data.map((j) => MediaModel.fromJson(j)).toList();
                                isLoading = false;
                              });
                            }
                          } catch (_) {
                            if (!searchDismissed && ctx.mounted) {
                              setSheetState(() => isLoading = false);
                            }
                          }
                        });
                      },
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : results.isEmpty
                            ? Center(
                                child: Text(
                                  searchController.text.trim().isEmpty
                                      ? l10n.searchHintEmpty
                                      : l10n.noResultsSearch,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
                                ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (_, i) {
                                  final item = results[i];
                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        width: 40, height: 60,
                                        child: item.posterUrl.isNotEmpty
                                            ? CachedNetworkImage(imageUrl: item.posterUrl, fit: BoxFit.cover)
                                            : Container(color: Theme.of(context).colorScheme.brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surface, child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20)),
                                        ),
                                      ),
                                      title: Text(item.title, style: const TextStyle(fontSize: 14)),
                                      subtitle: Text(item.year, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                    trailing: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                                    onTap: () async {
                                      final prefs = ref.read(soundPreferencesProvider);
                                      await SoundService.playAdd(prefs);
                                      // Add to library if not already
                                      final existing = await libRepo.getItemByTmdbId(item.id);
                                      String libId;
                                      if (existing != null) {
                                        libId = existing.id;
                                      } else {
                                        final newLibItem = LibraryItem(
                                          id: '',
                                          tmdbId: item.id,
                                          title: item.title,
                                          posterPath: item.posterPath,
                                          mediaType: item.mediaType,
                                          status: LibraryStatus.listed,
                                          category: item.mediaType == 'movie'
                                              ? LibraryCategory.movie
                                              : item.mediaType == 'tv'
                                                  ? LibraryCategory.series
                                                  : item.mediaType,
                                          year: item.year,
                                          addedAt: DateTime.now(),
                                        );
                                        await libRepo.addItem(newLibItem);
                                        final added = await libRepo.getItemByTmdbId(item.id);
                                        if (added == null) return;
                                        libId = added.id;
                                      }
                                      // Add to list if not already
                                      if (!_list.itemIds.contains(libId)) {
                                        await listRepo.addItemToList(_list.id, libId);
                                      }
                                      searchDismissed = true;
                                      showSuccessSnackBar = true;
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    searchDismissed = true;
    debounce?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.dispose();
    });
    if (showSuccessSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(l10n.addedToList),
      ));
    }
  }

  Future<void> _shareList() async {
    final l10n = AppLocalizations.of(context)!;
    final libItems = ref.read(libraryStreamProvider).valueOrNull ?? [];
    final items = libItems.where((item) => _list.itemIds.contains(item.id)).toList();

    final header = '${l10n.shareList(_list.name)}\n';
    final desc = _list.description.isNotEmpty
        ? '${l10n.shareListDescription(items.length, _list.description)}\n\n'
        : '';
    final itemList = items.isEmpty
        ? ''
        : '${l10n.shareListItems(_list.name)}\n${items.map((i) {
            final url = 'https://www.themoviedb.org/${i.mediaType}/${i.tmdbId}';
            return '• ${i.title} (${i.year}) - $url';
          }).join('\n')}';

    await Share.share('$header$desc$itemList');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allItems = ref.watch(libraryStreamProvider).whenData(
      (libItems) => libItems.where((item) => _list.itemIds.contains(item.id)).toList(),
    );
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isOwner = _list.ownerUid.isEmpty || _list.ownerUid == userId;
    final commentService = ref.watch(listCommentServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(_list.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            CustomListPrivacyBadge(isPublic: _list.isPublic, small: true),
          ],
        ),
        elevation: 0,
        actions: [
          if (isOwner)
            IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
              tooltip: l10n.addToList,
              onPressed: () {
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playClick(prefs);
                _addItem();
              },
            ),
          IconButton(
            icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurface),
            tooltip: l10n.share,
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              _shareList();
            },
          ),
          if (isOwner)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
              color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
              onSelected: (v) {
                if (v == 'edit') _editList();
                if (v == 'delete') _deleteList();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: ListTile(
                  leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  title: Text(l10n.edit, style: const TextStyle()),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
                PopupMenuItem(value: 'delete', child: ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
              ],
            ),
        ],
      ),
      body: allItems.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.error}: $e', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  final prefs = ref.read(soundPreferencesProvider);
                  SoundService.playClick(prefs);
                  ref.invalidate(libraryStreamProvider);
                },
                child: Text(l10n.retry, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        ),
        data: (items) {
          final cs = Theme.of(context).colorScheme;
          final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final isOwner = _list.ownerUid.isEmpty || _list.ownerUid == currentUid;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverBanner(isOwner, cs),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _list.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomListPrivacyBadge(isPublic: _list.isPublic, small: false),
                    ],
                  ),
                ),
                if (_list.isPublic) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final authorAsync = ref.watch(userProfileProvider(_list.ownerUid.isEmpty ? userId : _list.ownerUid));
                        final isFollowing = _list.followedBy.contains(userId);
                        return authorAsync.when(
                          data: (user) => Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: user?.photoURL.isNotEmpty == true
                                    ? CachedNetworkImageProvider(user!.photoURL)
                                    : null,
                                child: user?.photoURL.isEmpty == true
                                    ? const Icon(Icons.person, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user != null ? '${user.firstName} ${user.lastName}' : 'Usuario',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface),
                                    ),
                                    Text(
                                      'Autor de la lista',
                                      style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              if (_list.ownerUid.isNotEmpty && _list.ownerUid != userId)
                                SizedBox(
                                  width: 125,
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFollowing ? cs.surfaceContainerHigh : cs.primary,
                                      foregroundColor: isFollowing ? cs.onSurface : cs.onPrimary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      ref.read(customListRepositoryProvider).toggleFollow(_list.id, _list.ownerUid);
                                    },
                                    icon: Icon(isFollowing ? Icons.bookmark : Icons.bookmark_add_outlined, size: 14),
                                    label: Text(
                                      isFollowing ? l10n.following : l10n.follow,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ],
                if (_list.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(_list.description, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(l10n.itemsCount(items.length),
                      style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11)),
                ),
                if (_list.isPublic) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _list.likedByUser(userId) ? Icons.favorite : Icons.favorite_border,
                            color: _list.likedByUser(userId) ? Colors.red : cs.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            ref.read(customListRepositoryProvider).toggleLike(_list.id, _list.ownerUid.isEmpty ? userId : _list.ownerUid);
                            setState(() {
                              if (_list.likedByUser(userId)) {
                                _list = _list.copyWith(
                                  likedBy: _list.likedBy.where((id) => id != userId).toList(),
                                  likeCount: _list.likeCount - 1,
                                );
                              } else {
                                _list = _list.copyWith(
                                  likedBy: [..._list.likedBy, userId],
                                  likeCount: _list.likeCount + 1,
                                );
                              }
                            });
                          },
                        ),
                        Text('${_list.likeCount}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                        const SizedBox(width: 16),
                        StreamBuilder<int>(
                          stream: commentService.watchCommentCount(userId, _list.id),
                          builder: (context, snap) {
                            final count = snap.data ?? 0;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 16, color: cs.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('$count', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.people_outline, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${_list.followedBy.length}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.playlist_add, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(l10n.emptyList, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                          if (isOwner) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                final prefs = ref.read(soundPreferencesProvider);
                                SoundService.playClick(prefs);
                                _addItem();
                              },
                              icon: Icon(Icons.add, color: cs.primary),
                              label: Text(l10n.addToList, style: TextStyle(color: cs.primary)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) => _ListCard(
                      item: items[i],
                      onRemove: isOwner ? () => _removeItem(items[i]) : null,
                    ),
                  ),
                if (_list.isPublic || (currentUid.isNotEmpty && (_list.ownerUid.isEmpty || _list.ownerUid == currentUid))) ...[
                  const Divider(height: 1),
                  _ListCommentsSection(
                    ownerUid: _list.ownerUid.isEmpty ? currentUid : _list.ownerUid,
                    listId: _list.id,
                    commentService: commentService,
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ListCommentsSection extends ConsumerStatefulWidget {
  final String ownerUid;
  final String listId;
  final ListCommentService commentService;

  const _ListCommentsSection({
    required this.ownerUid,
    required this.listId,
    required this.commentService,
  });

  @override
  ConsumerState<_ListCommentsSection> createState() => _ListCommentsSectionState();
}

class _ListCommentsSectionState extends ConsumerState<_ListCommentsSection> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    widget.commentService.addComment(widget.ownerUid, widget.listId, text);
    _commentCtrl.clear();
  }

  void _showReplyDialog(String parentId, String parentUsername) {
    final replyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Responder a $parentUsername'),
        content: TextField(
          controller: replyCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final text = replyCtrl.text.trim();
              if (text.isNotEmpty) {
                widget.commentService.addComment(widget.ownerUid, widget.listId, text, parentId: parentId);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Responder'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String commentId, String currentText, DateTime timestamp) {
    if (isEditWindowExpired(timestamp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes editar comentarios dentro de los primeros 15 minutos')),
      );
      return;
    }
    final editCtrl = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: editCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Escribe tu comentario...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final newText = editCtrl.text.trim();
              if (newText.isNotEmpty) {
                await widget.commentService.editComment(widget.ownerUid, widget.listId, commentId, newText);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final commentsAsync = ref.watch(listCommentsProvider(
      (ownerUid: widget.ownerUid, listId: widget.listId),
    ));
    final countStream = widget.commentService.watchCommentCount(widget.ownerUid, widget.listId);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<int>(
            stream: countStream,
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return Row(
                children: [
                  Text('Comentarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count', style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                color: cs.primary,
                onPressed: _addComment,
              ),
            ],
          ),
          const SizedBox(height: 12),
          commentsAsync.when(
            loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Error al cargar comentarios: $err', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ),
            data: (comments) {
              final seen = <String>{};
              final topComments = comments
                  .where((c) => (c.parentId == null || c.parentId!.isEmpty) && seen.add(c.id))
                  .toList();
              if (topComments.isEmpty) {
                return Text('No hay comentarios aún',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topComments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _ListCommentTile(
                  key: ValueKey(topComments[i].id),
                  comment: topComments[i],
                  userId: userId,
                  ownerUid: widget.ownerUid,
                  listId: widget.listId,
                  commentService: widget.commentService,
                  onReply: () => _showReplyDialog(topComments[i].id, topComments[i].username),
                  onEdit: () => _showEditDialog(topComments[i].id, topComments[i].text, topComments[i].timestamp),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ListCommentTile extends ConsumerStatefulWidget {
  final ListComment comment;
  final String? userId;
  final String ownerUid;
  final String listId;
  final ListCommentService commentService;
  final VoidCallback onReply;
  final VoidCallback onEdit;

  const _ListCommentTile({
    super.key,
    required this.comment,
    required this.userId,
    required this.ownerUid,
    required this.listId,
    required this.commentService,
    required this.onReply,
    required this.onEdit,
  });

  @override
  ConsumerState<_ListCommentTile> createState() => _ListCommentTileState();
}

class _ListCommentTileState extends ConsumerState<_ListCommentTile> {
  bool _showReplies = false;
  Stream<List<ListComment>>? _repliesStream;

  @override
  void initState() {
    super.initState();
    _repliesStream = widget.commentService.watchReplies(widget.ownerUid, widget.listId, widget.comment.id);
  }

  @override
  void didUpdateWidget(_ListCommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment.id != oldWidget.comment.id ||
        widget.listId != oldWidget.listId ||
        widget.ownerUid != oldWidget.ownerUid) {
      _repliesStream = widget.commentService.watchReplies(widget.ownerUid, widget.listId, widget.comment.id);
    }
  }

  Future<void> _confirmDeleteComment(String ownerUid, String listId, String commentId, DateTime timestamp) async {
    if (isEditWindowExpired(timestamp)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes eliminar comentarios dentro de los primeros 15 minutos')),
        );
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Deseas eliminar este comentario?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      widget.commentService.deleteComment(ownerUid, listId, commentId);
    }
  }

  void _showEditReplyDialog(String commentId, String currentText, DateTime timestamp) {
    if (isEditWindowExpired(timestamp)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes editar comentarios dentro de los primeros 15 minutos')),
        );
      }
      return;
    }
    final editCtrl = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: editCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Escribe tu comentario...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final newText = editCtrl.text.trim();
              if (newText.isNotEmpty) {
                await widget.commentService.editComment(widget.ownerUid, widget.listId, commentId, newText);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.comment;
    final isOwner = c.userId == widget.userId;
    final canEdit = isOwner && canModifyComment(c.timestamp);
    final canDelete = isOwner && canModifyComment(c.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: c.avatarUrl != null ? NetworkImage(c.avatarUrl!) : null,
                child: c.avatarUrl == null
                    ? Text(c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 11))
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(c.username, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
                        const SizedBox(width: 6),
                        Text(_timeAgo(c.timestamp), style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                        if (c.editedAt != null) ...[
                          const SizedBox(width: 4),
                          Text('(editado)', style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
                        ],
                        const Spacer(),
                        if (canDelete)
                          GestureDetector(
                            onTap: () => _confirmDeleteComment(widget.ownerUid, widget.listId, c.id, c.timestamp),
                            child: Icon(Icons.delete_outline, size: 14, color: Colors.red.withValues(alpha: 0.6)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(c.text, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.commentService.toggleLike(widget.ownerUid, widget.listId, c.id),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                c.likes.contains(widget.userId) ? Icons.favorite : Icons.favorite_border,
                                size: 12,
                                color: c.likes.contains(widget.userId) ? Colors.red : cs.onSurfaceVariant,
                              ),
                              if (c.likes.isNotEmpty) ...[
                                const SizedBox(width: 2),
                                Text('${c.likes.length}', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: widget.onReply,
                          child: Text('Responder', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                        ),
                        if (canEdit) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: widget.onEdit,
                            child: Icon(Icons.edit, size: 14, color: cs.onSurfaceVariant),
                          ),
                        ],
                        const Spacer(),
                        if (!_showReplies)
                          GestureDetector(
                            onTap: () => setState(() => _showReplies = true),
                            child: Text('Ver respuestas', style: TextStyle(fontSize: 11, color: cs.primary)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showReplies && _repliesStream != null)
            StreamBuilder<List<ListComment>>(
              stream: _repliesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 44, top: 8),
                    child: Text('Error al cargar respuestas', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  );
                }
                final replies = snapshot.data ?? [];
                final seenReplies = <String>{};
                final uniqueReplies = replies
                    .where((c) => c.parentId == widget.comment.id && seenReplies.add(c.id))
                    .toList();
                if (uniqueReplies.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 44, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: uniqueReplies.map((reply) {
                      final isReplyOwner = reply.userId == widget.userId;
                      final canEditReply = isReplyOwner && canModifyComment(reply.timestamp);
                      final canDeleteReply = isReplyOwner && canModifyComment(reply.timestamp);
                      return Padding(
                        key: ValueKey(reply.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: reply.avatarUrl != null && reply.avatarUrl!.isNotEmpty
                                  ? NetworkImage(reply.avatarUrl!)
                                  : null,
                              child: reply.avatarUrl == null || reply.avatarUrl!.isEmpty
                                  ? Text(reply.username.isNotEmpty ? reply.username[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 10))
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(reply.username, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: cs.onSurface)),
                                      const SizedBox(width: 4),
                                      Text(_timeAgo(reply.timestamp), style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant)),
                                      if (reply.editedAt != null) ...[
                                        const SizedBox(width: 4),
                                        Text('(editado)', style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant)),
                                      ],
                                      if (canEditReply || canDeleteReply)
                                        const Spacer(),
                                      if (canEditReply) ...[
                                        GestureDetector(
                                          onTap: () => _showEditReplyDialog(reply.id, reply.text, reply.timestamp),
                                          child: Icon(Icons.edit, size: 12, color: cs.onSurfaceVariant),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (canDeleteReply)
                                        GestureDetector(
                                          onTap: () => _confirmDeleteComment(widget.ownerUid, widget.listId, reply.id, reply.timestamp),
                                          child: Icon(Icons.delete_outline, size: 12, color: Colors.red.withValues(alpha: 0.5)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(reply.text, style: TextStyle(fontSize: 12, color: cs.onSurface)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${diff.inDays ~/ 7}sem';
}

class _ListCard extends ConsumerWidget {
  final LibraryItem item;
  final VoidCallback? onRemove;
  const _ListCard({required this.item, this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final prefs = ref.read(soundPreferencesProvider);
        SoundService.playClick(prefs);
        context.push('/detail/${item.tmdbId}?type=${item.mediaType}');
      },
      onLongPress: onRemove != null ? () => _showOptions(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.posterUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: item.posterUrl, fit: BoxFit.cover, placeholder: (_, __) => Container(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest), errorWidget: (_, __, ___) => Container(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest, child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurfaceVariant)))
                      : Container(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest, child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                if (onRemove != null)
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                if (onRemove != null) onRemove!();
              },
            ),
          ],
        ),
      ),
    );
  }
}
