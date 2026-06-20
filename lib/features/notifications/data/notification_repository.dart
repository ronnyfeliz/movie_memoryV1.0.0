import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/notification_model.dart';
import '../domain/notification_category.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    if (userId.isEmpty) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<int> watchUnreadCount(String userId) {
    if (userId.isEmpty) return Stream.value(0);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    if (userId.isEmpty) return;
    final batch = _firestore.batch();
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
    required NotificationType type,
    NotificationCategory category = NotificationCategory.seriesUpdate,
    String? senderUid,
    String? senderName,
    String? senderPhotoUrl,
    String? targetId,
    String? targetType,
    int? mediaId,
    String? mediaTitle,
    String? mediaType,
    String? actionUrl,
    String? notificationId,
  }) async {
    if (recipientUid.isEmpty) return;
    if (recipientUid == senderUid) return;
    final notification = NotificationModel(
      id: notificationId ?? '',
      title: title,
      body: body,
      createdAt: DateTime.now(),
      type: type,
      category: category,
      senderUid: senderUid,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      targetId: targetId,
      targetType: targetType,
      mediaId: mediaId,
      mediaTitle: mediaTitle,
      mediaType: mediaType,
      actionUrl: actionUrl,
    );
    final docRef = _firestore
        .collection('users')
        .doc(recipientUid)
        .collection('notifications');

    if (notificationId != null && notificationId.isNotEmpty) {
      await docRef.doc(notificationId).set(notification.toMap());
    } else {
      await docRef.add(notification.toMap());
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsStreamProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});

final unreadNotificationsCountProvider = StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(notificationRepositoryProvider).watchUnreadCount(userId);
});
