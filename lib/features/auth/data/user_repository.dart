import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUserIfNotExists({
    String? firstName,
    String? lastName,
    int? age,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) return false;

    String resolvedFirstName = firstName ?? '';
    String resolvedLastName = lastName ?? '';

    if (resolvedFirstName.isEmpty && user.displayName != null) {
      final parts = user.displayName!.split(' ');
      resolvedFirstName = parts.first;
      resolvedLastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      firstName: resolvedFirstName,
      lastName: resolvedLastName,
      age: age ?? 0,
      photoURL: user.photoURL ?? '',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
    return true;
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updatePreferences(List<String> genres, List<String> types) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'preferences.genres': genres,
      'preferences.types': types,
    });
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set(updatedUser.toMap());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Sube la foto de perfil usando bytes en memoria para evitar el reciclaje
  /// del archivo temporal de Android. Incluye reintentos en putData y en
  /// getDownloadURL con espera progresiva.
  Future<String> uploadProfilePictureBytes(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    if (user.uid.isEmpty) throw Exception('El UID del usuario está vacío');
    if (bytes.isEmpty) throw Exception('El archivo de imagen está vacío');

    final storageRef = _buildProfileRef(user.uid);

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    // 1. Subir con reintentos
    await _putDataWithRetry(storageRef, bytes, metadata);

    // 2. Obtener URL pública con reintento + fallback manual
    final downloadUrl = await _getDownloadUrlWithRetry(storageRef);

    // 3. Actualizar Firestore con la nueva URL
    final userModel = await getCurrentUser();
    if (userModel != null) {
      final updated = userModel.copyWith(photoURL: downloadUrl);
      await updateUser(updated);
    }
    return downloadUrl;
  }

  /// Construye la referencia de Storage de forma segura.
  Reference _buildProfileRef(String uid) {
    return FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('profile.jpg');
  }

  /// Sube [bytes] a [ref] con reintentos progresivos.
  /// Firebase Storage puede rechazar la subida si el archivo temporal
  /// desapareció o por condiciones de red transitorias.
  Future<void> _putDataWithRetry(
    Reference ref,
    Uint8List bytes,
    SettableMetadata metadata, {
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        await ref.putData(bytes, metadata);
        return; // éxito
      } on FirebaseException catch (e) {
        attempt++;
        debugPrint('[Storage] putData error (intento $attempt): code=${e.code} message=${e.message}');
        if (attempt >= maxAttempts) rethrow;
        // Espera progresiva: 2s, 4s, 6s…
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  /// Legacy file-based upload. Delegates a [uploadProfilePictureBytes].
  Future<String> uploadProfilePicture(File file) async {
    if (!await file.exists()) {
      throw Exception('El archivo local no existe o no se puede leer');
    }
    final bytes = await file.readAsBytes();
    return uploadProfilePictureBytes(bytes);
  }

  /// Obtiene la URL de descarga con reintentos progresivos.
  /// Si todos los reintentos fallan, construye la URL manualmente
  /// y la verifica con un HEAD request.
  Future<String> _getDownloadUrlWithRetry(Reference ref, {int maxAttempts = 5}) async {
    int attempt = 0;
    while (true) {
      try {
        return await ref.getDownloadURL();
      } catch (e) {
        attempt++;
        debugPrint('[Storage] getDownloadURL error (intento $attempt): $e');
        if (attempt >= maxAttempts) {
          // Fallback: construir URL manual si getDownloadURL() falla
          // por eventual consistency de Firebase Storage.
          try {
            final bucket = ref.bucket;
            final path = ref.fullPath;
            final encoded = Uri.encodeComponent(path);
            final manualUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encoded?alt=media';
            debugPrint('[Storage] Fallback URL: $manualUrl');
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
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }

  Future<void> deleteUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final batch = _firestore.batch();
    final userDoc = _firestore.collection('users').doc(user.uid);
    batch.delete(userDoc);
    final librarySnap = await userDoc.collection('library').get();
    for (final doc in librarySnap.docs) {
      batch.delete(doc.reference);
    }
    final listsSnap = await userDoc.collection('customLists').get();
    for (final doc in listsSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
