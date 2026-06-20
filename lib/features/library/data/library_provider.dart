import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/library_item.dart';
import 'library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

final libraryStreamProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchLibrary();
});

final watchLaterProvider = Provider<AsyncValue<List<LibraryItem>>>((ref) {
  return ref.watch(libraryStreamProvider).whenData(
        (items) => items.where((i) => i.status == LibraryStatus.watchLater).toList(),
  );
});

final watchedProvider = Provider<AsyncValue<List<LibraryItem>>>((ref) {
  return ref.watch(libraryStreamProvider).whenData(
        (items) => items.where((i) => i.status == LibraryStatus.watched).toList(),
  );
});

final favoritesProvider = Provider<AsyncValue<List<LibraryItem>>>((ref) {
  return ref.watch(libraryStreamProvider).whenData(
        (items) => items.where((i) => i.isFavorite).toList(),
  );
});

final libraryItemByTmdbIdProvider = Provider.family<AsyncValue<LibraryItem?>, int>((ref, tmdbId) {
  return ref.watch(libraryStreamProvider).whenData(
        (items) {
          try {
            return items.firstWhere((i) => i.tmdbId == tmdbId);
          } catch (_) {
            return null;
          }
        },
  );
});