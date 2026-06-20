import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/list_comment_model.dart';
import '../../notifications/data/notification_repository.dart';
import '../../notifications/domain/notification_model.dart';
import '../../../shared/comment_utils.dart';

class ListCommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;
  String? get _username => _auth.currentUser?.displayName ?? _auth.currentUser?.email;
  String? get _avatarUrl => _auth.currentUser?.photoURL;

  CollectionReference _commentsRef(String ownerUid, String listId) =>
      _firestore.collection('users').doc(ownerUid).collection('listComments').doc(listId).collection('messages');

  Stream<List<ListComment>> watchComments(String ownerUid, String listId) async* {
    final uid = _uid;
    if (uid == ownerUid) {
      yield* _commentsRef(ownerUid, listId)
          .where('parentId', isEqualTo: null)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snap) {
            final seen = <String>{};
            return snap.docs
                .map((doc) => ListComment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .where((c) => (c.parentId == null || c.parentId!.isEmpty) && seen.add(c.id))
                .toList();
          });
      return;
    }

    final listStream = _firestore
        .collection('users')
        .doc(ownerUid)
        .collection('customLists')
        .doc(listId)
        .snapshots();

    StreamSubscription? commentsSub;
    final controller = StreamController<List<ListComment>>();
    
    final listSub = listStream.listen((listSnap) {
      commentsSub?.cancel();
      if (!listSnap.exists) {
        controller.add(<ListComment>[]);
        return;
      }
      final listData = listSnap.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) {
        controller.add(<ListComment>[]);
        return;
      }
      commentsSub = _commentsRef(ownerUid, listId)
          .where('parentId', isEqualTo: null)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snap) {
            final seen = <String>{};
            return snap.docs
                .map((doc) => ListComment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .where((c) => (c.parentId == null || c.parentId!.isEmpty) && seen.add(c.id))
                .toList();
          })
          .listen((comments) {
            controller.add(comments);
          }, onError: (err) {
            controller.addError(err);
          });
    }, onError: (err) {
      controller.addError(err);
    });

    controller.onCancel = () {
      listSub.cancel();
      commentsSub?.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  Stream<List<ListComment>> watchReplies(String ownerUid, String listId, String parentId) async* {
    final uid = _uid;
    if (uid == ownerUid) {
      yield* _commentsRef(ownerUid, listId)
          .where('parentId', isEqualTo: parentId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snap) {
            final seen = <String>{};
            return snap.docs
                .map((doc) {
                  final c = ListComment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  if (uid != null && c.likes.contains(uid)) {
                    return c.copyWith(isLikedByCurrentUser: true);
                  }
                  return c;
                })
                .where((c) => c.parentId == parentId && seen.add(c.id))
                .toList();
          });
      return;
    }

    final listStream = _firestore
        .collection('users')
        .doc(ownerUid)
        .collection('customLists')
        .doc(listId)
        .snapshots();

    StreamSubscription? repliesSub;
    final controller = StreamController<List<ListComment>>();

    final listSub = listStream.listen((listSnap) {
      repliesSub?.cancel();
      if (!listSnap.exists) {
        controller.add(<ListComment>[]);
        return;
      }
      final listData = listSnap.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) {
        controller.add(<ListComment>[]);
        return;
      }
      repliesSub = _commentsRef(ownerUid, listId)
          .where('parentId', isEqualTo: parentId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snap) {
            final seen = <String>{};
            return snap.docs
                .map((doc) {
                  final c = ListComment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  if (uid != null && c.likes.contains(uid)) {
                    return c.copyWith(isLikedByCurrentUser: true);
                  }
                  return c;
                })
                .where((c) => c.parentId == parentId && seen.add(c.id))
                .toList();
          })
          .listen((replies) {
            controller.add(replies);
          }, onError: (err) {
            controller.addError(err);
          });
    }, onError: (err) {
      controller.addError(err);
    });

    controller.onCancel = () {
      listSub.cancel();
      repliesSub?.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  Stream<int> watchCommentCount(String ownerUid, String listId) async* {
    final uid = _uid;
    if (uid == ownerUid) {
      yield* _commentsRef(ownerUid, listId)
          .snapshots()
          .map((snap) => snap.docs.length);
      return;
    }

    final listStream = _firestore
        .collection('users')
        .doc(ownerUid)
        .collection('customLists')
        .doc(listId)
        .snapshots();

    StreamSubscription? countSub;
    final controller = StreamController<int>();

    final listSub = listStream.listen((listSnap) {
      countSub?.cancel();
      if (!listSnap.exists) {
        controller.add(0);
        return;
      }
      final listData = listSnap.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) {
        controller.add(0);
        return;
      }
      countSub = _commentsRef(ownerUid, listId)
          .snapshots()
          .map((snap) => snap.docs.length)
          .listen((cnt) {
            controller.add(cnt);
          }, onError: (err) {
            controller.addError(err);
          });
    }, onError: (err) {
      controller.addError(err);
    });

    controller.onCancel = () {
      listSub.cancel();
      countSub?.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  Future<void> addComment(String ownerUid, String listId, String text, {String? parentId}) async {
    final uid = _uid;
    if (uid == null) return;

    if (ownerUid != uid) {
      final listDoc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
      if (!listDoc.exists) return;
      final listData = listDoc.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) return;
    }

    final docRef = await _commentsRef(ownerUid, listId).add({
      'userId': uid,
      'username': _username ?? 'Anonymous',
      'avatarUrl': _avatarUrl,
      'listOwnerUid': ownerUid,
      'listId': listId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'likes': <String>[],
      'parentId': parentId,
    });
    final commentId = docRef.id;

    try {
      final listDoc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
      final listName = listDoc.exists ? (listDoc.data()?['name'] ?? 'tu lista') : 'tu lista';

      if (parentId == null) {
        if (ownerUid != uid) {
          final senderName = _username ?? 'Un usuario';
          await NotificationRepository().sendNotification(
            recipientUid: ownerUid,
            title: 'Nuevo comentario en tu lista',
            body: '$senderName comentó en tu lista "$listName": "$text"',
            type: NotificationType.comment,
            senderUid: uid,
            senderName: senderName,
            senderPhotoUrl: _avatarUrl,
            targetId: listId,
            targetType: 'list',
            notificationId: 'comment_$commentId',
          );
        }
      } else {
        final parentDoc = await _commentsRef(ownerUid, listId).doc(parentId).get();
        if (parentDoc.exists) {
          final parentData = parentDoc.data() as Map<String, dynamic>;
          final parentUserId = parentData['userId'] as String?;
          if (parentUserId != null && parentUserId != uid) {
            final senderName = _username ?? 'Un usuario';
            await NotificationRepository().sendNotification(
              recipientUid: parentUserId,
              title: 'Respuesta a tu comentario',
              body: '$senderName respondió a tu comentario en la lista "$listName": "$text"',
              type: NotificationType.reply,
              senderUid: uid,
              senderName: senderName,
              senderPhotoUrl: _avatarUrl,
              targetId: listId,
              targetType: 'list',
              notificationId: 'reply_$commentId',
            );
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> editComment(String ownerUid, String listId, String commentId, String newText) async {
    final uid = _uid;
    if (uid == null) return;
    
    if (ownerUid != uid) {
      final listDoc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
      if (!listDoc.exists) return;
      final listData = listDoc.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) return;
    }

    final commentDoc = await _commentsRef(ownerUid, listId).doc(commentId).get();
    if (!commentDoc.exists) return;
    final data = commentDoc.data() as Map<String, dynamic>;
    if (data['userId'] != uid) return;
    final timestamp = DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String());
    if (isEditWindowExpired(timestamp)) return;
    await _commentsRef(ownerUid, listId).doc(commentId).update({
      'text': newText,
      'editedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteComment(String ownerUid, String listId, String commentId) async {
    final uid = _uid;
    if (uid == null) return;

    if (ownerUid != uid) {
      final listDoc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
      if (!listDoc.exists) return;
      final listData = listDoc.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) return;
    }

    final commentDoc = await _commentsRef(ownerUid, listId).doc(commentId).get();
    if (!commentDoc.exists) return;
    final data = commentDoc.data() as Map<String, dynamic>;
    if (data['userId'] != uid) return;
    final timestamp = DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String());
    if (isEditWindowExpired(timestamp)) return;
    final batch = _firestore.batch();
    batch.delete(_commentsRef(ownerUid, listId).doc(commentId));
    final replies = await _commentsRef(ownerUid, listId)
        .where('parentId', isEqualTo: commentId)
        .get();
    for (final reply in replies.docs) {
      batch.delete(reply.reference);
    }
    await batch.commit();
  }

  Future<void> toggleLike(String ownerUid, String listId, String commentId) async {
    final uid = _uid;
    if (uid == null) return;

    if (ownerUid != uid) {
      final listDoc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
      if (!listDoc.exists) return;
      final listData = listDoc.data();
      final isPublic = listData?['isPublic'] ?? false;
      if (!isPublic) return;
    }

    final doc = await _commentsRef(ownerUid, listId).doc(commentId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);
    if (likes.contains(uid)) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }
    await _commentsRef(ownerUid, listId).doc(commentId).update({'likes': likes});
  }
}
