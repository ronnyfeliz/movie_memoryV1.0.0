import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/custom_list_model.dart';
import '../../notifications/data/notification_repository.dart';
import '../../notifications/domain/notification_model.dart';
import '../../auth/data/user_repository.dart';

class CustomListRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _listsRef =>
      _firestore.collection('users').doc(_uid).collection('customLists');

  Stream<List<CustomListModel>> watchLists() {
    if (_uid == null) return const Stream.empty();
    return _listsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomListModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                  ownerUid: _uid!,
                ))
            .toList());
  }

  Future<String> createList(String name, String description, {bool isPublic = false}) async {
    if (_uid == null) throw Exception('Usuario no autenticado');
    final doc = await _listsRef.add({
      'name': name,
      'description': description,
      'itemIds': <String>[],
      'createdAt': DateTime.now().toIso8601String(),
      'coverUrl': null,
      'isPublic': isPublic,
      'likeCount': 0,
      'likedBy': <String>[],
      'followedBy': <String>[],
      'ownerUid': _uid!,
    });
    return doc.id;
  }

  Future<void> updateList(CustomListModel list) async {
    if (_uid == null) return;
    await _listsRef.doc(list.id).update(list.toMap());
  }

  Future<void> setListVisibility(String listId, bool isPublic) async {
    if (_uid == null) return;
    await _listsRef.doc(listId).update({'isPublic': isPublic});
  }

  Future<void> deleteList(String id) async {
    if (_uid == null) return;
    await _listsRef.doc(id).delete();
  }

  Future<void> addItemToList(String listId, String itemId) async {
    if (_uid == null) return;
    await _listsRef.doc(listId).update({
      'itemIds': FieldValue.arrayUnion([itemId]),
    });
  }

  Future<void> removeItemFromList(String listId, String itemId) async {
    if (_uid == null) return;
    await _listsRef.doc(listId).update({
      'itemIds': FieldValue.arrayRemove([itemId]),
    });
  }

  Future<void> toggleLike(String listId, String ownerUid) async {
    final uid = _uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiking = !likedBy.contains(uid);
    if (!isLiking) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }
    await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).update({
      'likedBy': likedBy,
      'likeCount': likedBy.length,
    });

    if (isLiking && ownerUid != uid) {
      try {
        final sender = await UserRepository().getCurrentUser();
        final senderName = sender != null ? '${sender.firstName} ${sender.lastName}' : 'Un usuario';
        await NotificationRepository().sendNotification(
          recipientUid: ownerUid,
          title: 'Me gusta en tu lista',
          body: '$senderName le dio Me gusta a tu lista "${data['name'] ?? ''}"',
          type: NotificationType.listLike,
          senderUid: uid,
          senderName: senderName,
          senderPhotoUrl: sender?.photoURL,
          targetId: listId,
          targetType: 'list',
          notificationId: 'like_${uid}_$listId',
        );
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> toggleFollow(String listId, String ownerUid) async {
    final uid = _uid;
    if (uid == null) return;
    final doc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final followedBy = List<String>.from(data['followedBy'] ?? []);
    final isFollowing = !followedBy.contains(uid);
    if (!isFollowing) {
      followedBy.remove(uid);
    } else {
      followedBy.add(uid);
    }
    await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).update({
      'followedBy': followedBy,
    });

    if (isFollowing && ownerUid != uid) {
      try {
        final sender = await UserRepository().getCurrentUser();
        final senderName = sender != null ? '${sender.firstName} ${sender.lastName}' : 'Un usuario';
        await NotificationRepository().sendNotification(
          recipientUid: ownerUid,
          title: 'Nuevo seguidor en tu lista',
          body: '$senderName comenzó a seguir tu lista "${data['name'] ?? ''}"',
          type: NotificationType.listFollow,
          senderUid: uid,
          senderName: senderName,
          senderPhotoUrl: sender?.photoURL,
          targetId: listId,
          targetType: 'list',
          notificationId: 'follow_${uid}_$listId',
        );
      } catch (e) {
        // ignore
      }
    }
  }

  Future<CustomListModel?> getPublicList(String ownerUid, String listId) async {
    final doc = await _firestore.collection('users').doc(ownerUid).collection('customLists').doc(listId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    if (data['isPublic'] != true) return null;
    return CustomListModel.fromMap(doc.id, data, ownerUid: ownerUid);
  }

  Stream<List<CustomListModel>> watchPublicLists() {
    final snapshots = _firestore.collectionGroup('customLists')
        .where('isPublic', isEqualTo: true)
        .snapshots();
    return snapshots.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<CustomListModel>>.fromHandlers(
        handleData: (snap, sink) {
          final lists = snap.docs
              .map((doc) {
                final parts = doc.reference.path.split('/');
                final extractedOwnerUid = parts.length >= 2 ? parts[1] : '';
                return CustomListModel.fromMap(doc.id, doc.data(), ownerUid: extractedOwnerUid);
              })
              .toList();
          sink.add(lists);
        },
        handleError: (e, st, sink) {
          debugPrint('[Firestore] watchPublicLists error: $e');
          if (e is FirebaseException) {
            debugPrint('[Firestore] code=${e.code} message=${e.message}');
          }
          if (e is FirebaseException && (e.code == 'failed-precondition' || e.code == 'FAILED_PRECONDITION')) {
            debugPrint('[Firestore] watchPublicLists: missing collectionGroup index — returning empty list');
            sink.add([]);
          } else {
            sink.addError(e, st);
          }
        },
      ),
    );
  }

  Stream<List<CustomListModel>> watchFollowedLists() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    final snapshots = _firestore
        .collectionGroup('customLists')
        .where('followedBy', arrayContains: uid)
        .snapshots();
    return snapshots.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<CustomListModel>>.fromHandlers(
        handleData: (snap, sink) {
          sink.add(snap.docs.map((doc) {
            final parts = doc.reference.path.split('/');
            final extractedOwnerUid = parts.length >= 2 ? parts[1] : '';
            return CustomListModel.fromMap(doc.id, doc.data(), ownerUid: extractedOwnerUid);
          }).toList());
        },
        handleError: (e, st, sink) {
          debugPrint('[Firestore] watchFollowedLists error: $e');
          if (e is FirebaseException && (e.code == 'failed-precondition' || e.code == 'FAILED_PRECONDITION')) {
            debugPrint('[Firestore] watchFollowedLists: missing index — returning empty list');
            sink.add([]);
          } else {
            sink.addError(e, st);
          }
        },
      ),
    );
  }

  Stream<List<CustomListModel>> watchLikedLists() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    final snapshots = _firestore
        .collectionGroup('customLists')
        .where('likedBy', arrayContains: uid)
        .snapshots();
    return snapshots.transform(
      StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<CustomListModel>>.fromHandlers(
        handleData: (snap, sink) {
          sink.add(snap.docs.map((doc) {
            final parts = doc.reference.path.split('/');
            final extractedOwnerUid = parts.length >= 2 ? parts[1] : '';
            return CustomListModel.fromMap(doc.id, doc.data(), ownerUid: extractedOwnerUid);
          }).toList());
        },
        handleError: (e, st, sink) {
          debugPrint('[Firestore] watchLikedLists error: $e');
          if (e is FirebaseException && (e.code == 'failed-precondition' || e.code == 'FAILED_PRECONDITION')) {
            debugPrint('[Firestore] watchLikedLists: missing index — returning empty list');
            sink.add([]);
          } else {
            sink.addError(e, st);
          }
        },
      ),
    );
  }

  /// Uploads a cover image using raw bytes already read from disk.
  /// PREFERRED over [uploadListCover] when the source is a UCrop temp file,
  /// because Android may recycle the temp file descriptor mid-upload.
  Future<String> uploadListCoverBytes(String listId, Uint8List bytes) async {
    final uid = _uid;
    if (uid == null) throw Exception('Usuario no autenticado');
    if (bytes.isEmpty) throw Exception('Los bytes de la imagen están vacíos');

    // Sanitize the listId to ensure a valid Storage path segment.
    final safeId = listId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    if (safeId.isEmpty) throw Exception('El ID de la lista no es válido para Storage');

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('customLists')
        .child(safeId)
        .child('cover.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    // putData() reads from the in-memory Uint8List, so the temp file
    // lifecycle on Android is completely irrelevant.
    await storageRef.putData(bytes, metadata);
    final downloadUrl = await _getDownloadUrlWithRetry(storageRef);

    // Persist the download URL to Firestore.
    await _listsRef.doc(listId).update({'coverUrl': downloadUrl});
    return downloadUrl;
  }

  /// Legacy file-based upload. Delegates to [uploadListCoverBytes] to apply
  /// the same safety guarantees.
  Future<String> uploadListCover(String listId, File file) async {
    if (_uid == null) throw Exception('Usuario no autenticado');
    if (!await file.exists()) {
      throw Exception('El archivo local no existe o no se puede leer');
    }
    final bytes = await file.readAsBytes();
    return uploadListCoverBytes(listId, bytes);
  }

  Future<String> _getDownloadUrlWithRetry(Reference ref, {int maxAttempts = 5}) async {
    int attempts = 0;
    while (true) {
      try {
        return await ref.getDownloadURL();
      } catch (e) {
        debugPrint('[Storage] getDownloadURL error (attempt ${attempts + 1}): $e');
        attempts++;
        if (attempts >= maxAttempts) {
          // Fallback: construir URL manual si getDownloadURL() falla
          // con object-not-found (problema conocido de Firebase Storage
          // cuando el índice tarda en propagarse).
          try {
            final bucket = ref.bucket;
            final path = ref.fullPath;
            final encoded = Uri.encodeComponent(path);
            final manualUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encoded?alt=media';
            debugPrint('[Storage] Fallback URL: $manualUrl');
            // Verificar que la URL funciona con una petición HEAD
            final client = http.Client();
            try {
              final head = await client.head(Uri.parse(manualUrl)).timeout(const Duration(seconds: 5));
              if (head.statusCode == 200) {
                return manualUrl;
              }
            } finally {
              client.close();
            }
          } catch (fb) {
            debugPrint('[Storage] Fallback falló también: $fb');
          }
          rethrow;
        }
        // Espera progresiva: 1s, 2s, 3s, 4s
        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  Future<void> removeListCover(String listId) async {
    if (_uid == null) return;
    await _listsRef.doc(listId).update({'coverUrl': null});
    
    try {
      final safeId = listId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(_uid!)
          .child('customLists')
          .child(safeId)
          .child('cover.jpg');
      await ref.delete();
    } catch (_) {
      // Ignorar si no existe
    }
  }
}
