import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/library_item.dart';

class LibraryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _libraryRef =>
      _firestore.collection('users').doc(_uid).collection('library');

  Stream<List<LibraryItem>> watchLibrary() {
    if (_uid == null) return const Stream.empty();
    return _libraryRef
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => LibraryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addItem(LibraryItem item) async {
    if (_uid == null) return;
    await _libraryRef.add(item.toMap());
  }

  Future<void> updateItem(LibraryItem item) async {
    if (_uid == null) return;
    await _libraryRef.doc(item.id).update(item.toMap());
  }

  Future<void> removeItem(String id) async {
    if (_uid == null) return;
    await _libraryRef.doc(id).delete();
  }

  Future<bool> isInLibrary(int tmdbId) async {
    if (_uid == null) return false;
    final snap = await _libraryRef
        .where('tmdbId', isEqualTo: tmdbId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<LibraryItem?> getItemByTmdbId(int tmdbId) async {
    if (_uid == null) return null;
    final snap = await _libraryRef
        .where('tmdbId', isEqualTo: tmdbId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return LibraryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}