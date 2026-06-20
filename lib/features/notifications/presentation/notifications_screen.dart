import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../domain/notification_model.dart';
import '../domain/notification_category.dart';
import '../data/notification_repository.dart';
import '../../library/domain/custom_list_model.dart';
import '../../library/presentation/list_detail_screen.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? _selectedCategory;

  Future<void> _handleNotificationTap(BuildContext context, WidgetRef ref, NotificationModel notification) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    await ref.read(notificationRepositoryProvider).markAsRead(uid, notification.id);

    if (notification.actionUrl != null && notification.mediaId != null) {
      if (!context.mounted) return;
      final type = notification.mediaType ?? 'movie';
      Navigator.pushReplacementNamed(context, '/detail/${notification.mediaId}', arguments: {'type': type});
      return;
    }

    if (notification.targetType == 'list' && notification.targetId != null) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        CustomListModel? list;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('customLists')
            .doc(notification.targetId)
            .get();
        if (doc.exists) {
          list = CustomListModel.fromMap(doc.id, doc.data()!, ownerUid: uid);
        } else if (notification.senderUid != null) {
          final docSender = await FirebaseFirestore.instance
              .collection('users')
              .doc(notification.senderUid)
              .collection('customLists')
              .doc(notification.targetId)
              .get();
          if (docSender.exists) {
            list = CustomListModel.fromMap(docSender.id, docSender.data()!, ownerUid: notification.senderUid!);
          }
        }

        if (context.mounted) Navigator.pop(context);

        if (list != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ListDetailScreen(list: list!)),
          );
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Esta lista ya no existe o es privada')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al abrir la lista: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final notificationsAsync = ref.watch(notificationsStreamProvider(uid));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Marcar todas como leídas',
            onPressed: () async {
              final prefs = ref.read(soundPreferencesProvider);
              await SoundService.playClick(prefs);
              await ref.read(notificationRepositoryProvider).markAllAsRead(uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _FilterChip(
                  label: 'Todas',
                  selected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...NotificationCategory.values.map((cat) => _FilterChip(
                  label: cat.shortName,
                  selected: _selectedCategory == cat,
                  onTap: () => setState(() => _selectedCategory = _selectedCategory == cat ? null : cat),
                )),
              ],
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Error: $err', style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              data: (notifications) {
                final filtered = _selectedCategory != null
                    ? notifications.where((n) => n.category == _selectedCategory).toList()
                    : notifications;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes notificaciones todavía',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final n = filtered[index];
                    return _NotificationTile(
                      notification: n,
                      onTap: () => _handleNotificationTap(context, ref, n),
                    );
                  },
                );
              },
            ),
          ),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData _getIcon() {
    if (notification.category == NotificationCategory.newEpisode ||
        notification.category == NotificationCategory.newSeason) {
      return Icons.tv_outlined;
    }
    if (notification.category == NotificationCategory.movieRelease) {
      return Icons.movie_outlined;
    }
    if (notification.category == NotificationCategory.seriesRelease) {
      return Icons.live_tv_outlined;
    }
    if (notification.category == NotificationCategory.dailyRecommendation) {
      return Icons.wb_sunny_outlined;
    }
    if (notification.category == NotificationCategory.seriesUpdate) {
      return Icons.notifications_active_outlined;
    }
    switch (notification.type) {
      case NotificationType.newFollower:
        return Icons.person_add_outlined;
      case NotificationType.listFollow:
        return Icons.bookmark_added_outlined;
      case NotificationType.listLike:
        return Icons.favorite_border;
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      case NotificationType.reply:
        return Icons.quickreply_outlined;
      case NotificationType.general:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(ColorScheme cs) {
    if (notification.category == NotificationCategory.newEpisode ||
        notification.category == NotificationCategory.newSeason) {
      return Colors.teal;
    }
    if (notification.category == NotificationCategory.movieRelease) {
      return Colors.orange;
    }
    if (notification.category == NotificationCategory.seriesRelease) {
      return Colors.purple;
    }
    if (notification.category == NotificationCategory.dailyRecommendation) {
      return Colors.amber;
    }
    if (notification.category == NotificationCategory.seriesUpdate) {
      return Colors.indigo;
    }
    switch (notification.type) {
      case NotificationType.listLike:
        return Colors.red;
      case NotificationType.newFollower:
      case NotificationType.listFollow:
        return Colors.blue;
      case NotificationType.comment:
      case NotificationType.reply:
        return Colors.green;
      case NotificationType.general:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeStr = DateFormat('dd/MM HH:mm').format(notification.createdAt);

    return Container(
      color: notification.isRead ? Colors.transparent : cs.primary.withValues(alpha: 0.05),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: cs.surfaceContainerHigh,
              backgroundImage: notification.senderPhotoUrl != null && notification.senderPhotoUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(notification.senderPhotoUrl!)
                  : null,
              child: notification.senderPhotoUrl == null || notification.senderPhotoUrl!.isEmpty
                  ? Icon(_getIcon(), size: 18, color: _getIconColor(cs))
                  : null,
            ),
            if (notification.senderPhotoUrl != null && notification.senderPhotoUrl!.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Icon(
                    _getIcon(),
                    size: 10,
                    color: _getIconColor(cs),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            notification.body,
            style: TextStyle(
              fontSize: 12,
              color: notification.isRead ? cs.onSurfaceVariant : cs.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
