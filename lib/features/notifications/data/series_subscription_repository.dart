import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/series_subscription_model.dart';

class SeriesSubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _subscriptionsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('seriesSubscriptions');
  }

  Stream<List<SeriesSubscription>> watchSubscriptions(String userId) {
    if (userId.isEmpty) return const Stream.empty();
    return _subscriptionsRef(userId)
        .orderBy('subscribedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SeriesSubscription.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<SeriesSubscription?> getSubscription(String userId, int tmdbId) async {
    if (userId.isEmpty) return null;
    final snap = await _subscriptionsRef(userId)
        .where('tmdbId', isEqualTo: tmdbId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return SeriesSubscription.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<bool> isSubscribed(String userId, int tmdbId) async {
    if (userId.isEmpty) return false;
    final snap = await _subscriptionsRef(userId)
        .where('tmdbId', isEqualTo: tmdbId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> subscribe(String userId, SeriesSubscription subscription) async {
    if (userId.isEmpty) return;
    final existing = await getSubscription(userId, subscription.tmdbId);
    if (existing != null) return;
    await _subscriptionsRef(userId).add(subscription.toMap());
  }

  Future<void> unsubscribe(String userId, int tmdbId) async {
    if (userId.isEmpty) return;
    final snap = await _subscriptionsRef(userId)
        .where('tmdbId', isEqualTo: tmdbId)
        .limit(1)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> toggleSubscription(String userId, int tmdbId, String title, String posterPath, String mediaType) async {
    if (userId.isEmpty) return;
    final existing = await getSubscription(userId, tmdbId);
    if (existing != null) {
      await unsubscribe(userId, tmdbId);
    } else {
      await subscribe(userId, SeriesSubscription(
        id: '',
        tmdbId: tmdbId,
        title: title,
        posterPath: posterPath,
        mediaType: mediaType,
        subscribedAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateSubscription(String userId, SeriesSubscription subscription) async {
    if (userId.isEmpty) return;
    await _subscriptionsRef(userId).doc(subscription.id).update(subscription.toMap());
  }
}

final seriesSubscriptionRepositoryProvider = Provider<SeriesSubscriptionRepository>((ref) {
  return SeriesSubscriptionRepository();
});

final seriesSubscriptionsStreamProvider = StreamProvider.family<List<SeriesSubscription>, String>((ref, userId) {
  return ref.watch(seriesSubscriptionRepositoryProvider).watchSubscriptions(userId);
});

final isSubscribedToSeriesProvider = FutureProvider.family<bool, ({String userId, int tmdbId})>((ref, params) {
  return ref.watch(seriesSubscriptionRepositoryProvider).isSubscribed(params.userId, params.tmdbId);
});
