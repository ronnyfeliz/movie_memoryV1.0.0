abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(
      String email,
      String password, {
        String? firstName,
        String? lastName,
        int? age,
      });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<void> deleteAccount();
  Stream<bool> get authStateChanges;
}