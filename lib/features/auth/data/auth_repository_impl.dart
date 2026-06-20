import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_repository.dart';
import 'user_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepo = UserRepository();

  @override
  Stream<bool> get authStateChanges =>
      _auth.authStateChanges().map((user) => user != null);

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    await _userRepo.createUserIfNotExists();
  }
  @override
  Future<void> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null && !credential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('Debes verificar tu correo antes de iniciar sesión. Revisa tu bandeja de entrada.');
    }
  }

  @override
  Future<void> signUpWithEmail(
      String email,
      String password, {
        String? firstName,
        String? lastName,
        int? age,
      }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    await _userRepo.createUserIfNotExists(
      firstName: firstName,
      lastName: lastName,
      age: age,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _userRepo.deleteUserData();
    await user.delete();
    await _googleSignIn.signOut();
  }
}