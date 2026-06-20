import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notification/notification_provider.dart';
import '../domain/notification_category.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Notificaciones', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Activar o desactivar todas las notificaciones'),
            value: prefs.enabled,
            activeTrackColor: cs.primary.withValues(alpha: 0.5),
            activeThumbColor: cs.primary,
            onChanged: (v) => ref.read(notificationPreferencesProvider.notifier).setEnabled(v),
          ),
          if (prefs.enabled) ...[
            const SizedBox(height: 8),
            ...NotificationMode.values.map((mode) {
              final isSelected = prefs.mode == mode;
              final label = switch (mode) {
                NotificationMode.normal => 'Normal',
                NotificationMode.popup => 'Pop-up',
                NotificationMode.both => 'Ambos',
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  tileColor: isSelected
                      ? cs.primary.withValues(alpha: 0.15)
                      : cs.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? cs.primary : Colors.transparent,
                    ),
                  ),
                  title: Text(label, style: TextStyle(
                    color: isSelected ? cs.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: cs.primary)
                      : null,
                  onTap: () {
                    ref.read(soundPreferencesProvider.notifier).toggle('click', true);
                    ref.read(notificationPreferencesProvider.notifier).setMode(mode);
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Categorías',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...NotificationCategory.values.map((cat) {
              final isCatEnabled = prefs.isCategoryEnabled(cat);
              return SwitchListTile(
                title: Text(cat.displayName, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  'Recibir notificaciones sobre ${cat.shortName.toLowerCase()}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                value: isCatEnabled,
                activeTrackColor: cs.primary.withValues(alpha: 0.5),
                activeThumbColor: cs.primary,
                onChanged: (v) {
                  ref.read(soundPreferencesProvider.notifier).toggle('click', true);
                  ref.read(notificationPreferencesProvider.notifier).setCategoryEnabled(cat, v);
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}
