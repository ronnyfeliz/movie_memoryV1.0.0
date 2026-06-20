import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'comment_model.dart';
import '../shared/comment_utils.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;
  String? get _username => _auth.currentUser?.displayName ?? _auth.currentUser?.email;
  String? get _avatarUrl => _auth.currentUser?.photoURL;

  CollectionReference _commentsRef(int tmdbId) =>
      _firestore.collection('comments').doc(tmdbId.toString()).collection('messages');

  Stream<List<CommentModel>> watchComments(int tmdbId) {
    return _commentsRef(tmdbId)
        .where('parentId', isEqualTo: null)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      final comments = snap.docs
          .map((doc) => CommentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      for (final c in comments) {
        if (_uid != null) {
          c.setLikedByCurrentUser(c.likes.contains(_uid));
        }
      }
      return comments;
    });
  }

  Stream<List<CommentModel>> watchReplies(int tmdbId, String parentId) {
    return _commentsRef(tmdbId)
        .where('parentId', isEqualTo: parentId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) {
      final replies = snap.docs
          .map((doc) => CommentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      for (final c in replies) {
        if (_uid != null) {
          c.setLikedByCurrentUser(c.likes.contains(_uid));
        }
      }
      return replies;
    });
  }

  Stream<int> watchCommentCount(int tmdbId) {
    return _commentsRef(tmdbId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> addComment(int tmdbId, String text, {String? parentId}) async {
    if (_uid == null) return;
    final comment = CommentModel(
      id: '',
      userId: _uid!,
      username: _username ?? 'Anonymous',
      avatarUrl: _avatarUrl,
      contentId: tmdbId.toString(),
      text: text,
      timestamp: DateTime.now(),
      parentId: parentId,
    );
    await _commentsRef(tmdbId).add(comment.toMap());
  }

  Future<void> editComment(int tmdbId, String commentId, String newText) async {
    if (_uid == null) return;
    final doc = await _commentsRef(tmdbId).doc(commentId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != _uid) return;
    final timestamp = DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String());
    if (isEditWindowExpired(timestamp)) return;
    await _commentsRef(tmdbId).doc(commentId).update({
      'text': newText,
      'editedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteComment(int tmdbId, String commentId) async {
    if (_uid == null) return;
    final doc = await _commentsRef(tmdbId).doc(commentId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != _uid) return;
    final timestamp = DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String());
    if (isEditWindowExpired(timestamp)) return;
    final batch = _firestore.batch();
    final docRef = _commentsRef(tmdbId).doc(commentId);
    batch.delete(docRef);
    final replies = await _commentsRef(tmdbId)
        .where('parentId', isEqualTo: commentId)
        .get();
    for (final reply in replies.docs) {
      batch.delete(reply.reference);
    }
    await batch.commit();
  }

  Future<void> toggleLike(int tmdbId, String commentId) async {
    if (_uid == null) return;
    final doc = await _commentsRef(tmdbId).doc(commentId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);
    if (likes.contains(_uid)) {
      likes.remove(_uid);
    } else {
      likes.add(_uid!);
    }
    await _commentsRef(tmdbId).doc(commentId).update({'likes': likes});
  }
}
