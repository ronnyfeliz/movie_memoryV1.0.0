import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

final _profileUserProvider = FutureProvider<UserModel?>((ref) {
  return UserRepository().getCurrentUser();
});

final _profileStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Future.value({'total': 0, 'watched': 0, 'favorites': 0});
  final firestore = FirebaseFirestore.instance;
  final lib = firestore.collection('users').doc(uid).collection('library');
  return Future.wait([
    lib.count().get().then((s) => s.count ?? 0),
    lib.where('status', isEqualTo: 'watched').count().get().then((s) => s.count ?? 0),
    lib.where('isFavorite', isEqualTo: true).count().get().then((s) => s.count ?? 0),
  ]).then((r) => {'total': r[0], 'watched': r[1], 'favorites': r[2]});
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(_profileUserProvider);
    final statsAsync = ref.watch(_profileStatsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e', style: const TextStyle(color: Colors.red))),
        data: (user) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: user?.photoURL.isNotEmpty == true
                        ? CachedNetworkImageProvider(user!.photoURL)
                        : null,
                    child: user?.photoURL.isNotEmpty != true
                        ? Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user != null ? '${user.firstName} ${user.lastName}' : l10n.user,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(user!.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                  ],
                  const SizedBox(height: 8),
                  if (user?.createdAt != null)
                    Text('${l10n.memberSince} ${_formatDate(user!.createdAt)}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            statsAsync.when(
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox.shrink(),
              data: (stats) => Row(
                children: [
                  _StatCard(label: l10n.total, value: '${stats['total']}', icon: Icons.collections_bookmark),
                  _StatCard(label: l10n.viewed, value: '${stats['watched']}', icon: Icons.visibility),
                  _StatCard(label: l10n.favorites, value: '${stats['favorites']}', icon: Icons.favorite),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(l10n.editProfile),
              trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onTap: () {
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playClick(prefs);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(l10n.settings),
              trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onTap: () {
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playClick(prefs);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(l10n.about),
              trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onTap: () {
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playClick(prefs);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(l10n.deleteAccount, style: const TextStyle(color: Colors.red)),
              onTap: () async {
                final prefs = ref.read(soundPreferencesProvider);
                await SoundService.playClick(prefs);
                if (!context.mounted) return;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.deleteAccountTitle, style: const TextStyle(color: Colors.red)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.deleteAccountMessage, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 16),
                        Text(l10n.deleteAccountConfirm, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
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
                          final prefs = ref.read(soundPreferencesProvider);
                          SoundService.playRemove(prefs);
                          Navigator.pop(ctx, true);
                        },
                        child: Text(l10n.deleteAccount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
                if (confirm != true || !context.mounted) return;
                await ref.read(authNotifierProvider.notifier).deleteAccount();
                if (context.mounted) context.go('/login');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurfaceVariant),
              title: Text(l10n.logout),
              onTap: () async {
                final prefs = ref.read(soundPreferencesProvider);
                await SoundService.playClick(prefs);
                if (!context.mounted) return;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.logoutTitle, style: const TextStyle()),
                    content: Text(l10n.logoutMessage, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                          final prefs = ref.read(soundPreferencesProvider);
                          SoundService.playClick(prefs);
                          Navigator.pop(ctx, true);
                        },
                        child: Text(l10n.logout, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm != true || !context.mounted) return;
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
