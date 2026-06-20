import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/custom_list_model.dart';
import '../domain/library_item.dart';
import 'custom_list_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/data/user_repository.dart';

final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  return CustomListRepository();
});

final customListsStreamProvider = StreamProvider<List<CustomListModel>>((ref) {
  return ref.watch(customListRepositoryProvider).watchLists();
});

final publicListsStreamProvider = StreamProvider<List<CustomListModel>>((ref) {
  return ref.watch(customListRepositoryProvider).watchPublicLists();
});

final followedListsStreamProvider = StreamProvider<List<CustomListModel>>((ref) {
  return ref.watch(customListRepositoryProvider).watchFollowedLists();
});

final likedListsStreamProvider = StreamProvider<List<CustomListModel>>((ref) {
  return ref.watch(customListRepositoryProvider).watchLikedLists();
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  if (uid.isEmpty) return null;
  return UserRepository().getUserById(uid);
});

final listItemsProvider = StreamProvider.family<List<LibraryItem>, CustomListModel>((ref, list) {
  final ownerUid = list.ownerUid.isEmpty 
      ? (FirebaseAuth.instance.currentUser?.uid ?? '') 
      : list.ownerUid;
  if (ownerUid.isEmpty || list.id.isEmpty) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(ownerUid)
      .collection('customLists')
      .doc(list.id)
      .snapshots()
      .asyncMap((listDoc) async {
        if (!listDoc.exists) return <LibraryItem>[];
        final itemIds = List<String>.from(listDoc.data()?['itemIds'] ?? []);
        if (itemIds.isEmpty) return <LibraryItem>[];
        
        final libSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(ownerUid)
            .collection('library')
            .get();
        
        return libSnap.docs
            .map((doc) => LibraryItem.fromMap(doc.id, doc.data()))
            .where((item) => itemIds.contains(item.id))
            .toList();
      });
});

final listPostersProvider = Provider.family<AsyncValue<List<String>>, CustomListModel>((ref, list) {
  return ref.watch(listItemsProvider(list)).whenData((items) {
    return items
        .map((i) => i.posterPath.isNotEmpty 
            ? (i.posterPath.startsWith('http') ? i.posterPath : 'https://image.tmdb.org/t/p/w200${i.posterPath}') 
            : '')
        .where((path) => path.isNotEmpty)
        .toList();
  });
});
