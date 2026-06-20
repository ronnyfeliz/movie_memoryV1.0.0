import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/discover/data/discover_provider.dart';
import '../data/user_repository.dart';
import 'package:movie_memory/core/sound/sound_service.dart';
import 'package:movie_memory/core/sound/sound_provider.dart';
import 'auth_provider.dart';

final _selectedGenresProvider = StateProvider<List<int>>((ref) => []);
final _selectedTypesProvider = StateProvider<List<String>>((ref) => []);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final genresAsync = ref.watch(_genresProvider);
    final userAsync = ref.watch(currentUserProvider);

    if (!_initialized) {
      userAsync.whenData((user) {
        if (user != null) {
          _initialized = true;
          final loadedGenres = user.preferredGenres.map((id) => int.tryParse(id)).whereType<int>().toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(_selectedGenresProvider.notifier).state = loadedGenres;
              ref.read(_selectedTypesProvider.notifier).state = user.preferredTypes;
            }
          });
        }
      });
    }

    final l10n = AppLocalizations.of(context)!;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: canPop,
      ),
      body: genresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (genres) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.yourPreferences, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l10n.selectFavoriteGenres,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4)),
                const SizedBox(height: 24),
                Text(l10n.favoriteGenres, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: genres.map((g) => _GenreChip(
                    label: g['name'] as String,
                    genreId: g['id'] as int,
                  )).toList(),
                ),
                const SizedBox(height: 28),
                Text(l10n.contentTypes, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _TypeChip(label: l10n.movie, value: 'movie'),
                    _TypeChip(label: l10n.series, value: 'series'),
                    _TypeChip(label: l10n.anime, value: 'anime'),
                    _TypeChip(label: l10n.documentary, value: 'documentary'),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveAndContinue(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.start, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final prefs = ref.read(soundPreferencesProvider);
                      await SoundService.playClick(prefs);
                      if (context.mounted) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/discover');
                        }
                      }
                    },
                    child: Text(l10n.skip, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveAndContinue(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playConfirm(prefs);
    final genres = ref.read(_selectedGenresProvider);
    final types = ref.read(_selectedTypesProvider);
    await UserRepository().updatePreferences(
      genres.map((id) => id.toString()).toList(),
      types,
    );
    ref.invalidate(currentUserProvider);
    if (context.mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.go('/discover');
      }
    }
  }
}

final _genresProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(tmdbApiProvider).getMovieGenres();
});

class _GenreChip extends ConsumerWidget {
  final String label;
  final int genreId;
  const _GenreChip({required this.label, required this.genreId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedGenresProvider).contains(genreId);
    return GestureDetector(
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playClick(prefs);
        final notifier = ref.read(_selectedGenresProvider.notifier);
        if (selected) {
          notifier.state = notifier.state.where((id) => id != genreId).toList();
        } else {
          notifier.state = [...notifier.state, genreId];
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        )),
      ),
    );
  }
}

class _TypeChip extends ConsumerWidget {
  final String label;
  final String value;
  const _TypeChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedTypesProvider).contains(value);
    return GestureDetector(
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playClick(prefs);
        final notifier = ref.read(_selectedTypesProvider.notifier);
        if (selected) {
          notifier.state = notifier.state.where((v) => v != value).toList();
        } else {
          notifier.state = [...notifier.state, value];
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        )),
      ),
    );
  }
}
