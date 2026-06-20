import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository_impl.dart';
import '../data/user_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final onboardingRequiredProvider = StateProvider<bool>((ref) => false);

final currentUserProvider = FutureProvider<UserModel?>((ref) {
  return UserRepository().getCurrentUser();
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> _checkOnboarding() async {
    final user = await UserRepository().getCurrentUser();
    if (user != null && user.preferredGenres.isEmpty) {
      _ref.read(onboardingRequiredProvider.notifier).state = true;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.signInWithGoogle());
    if (!state.hasError) await _checkOnboarding();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.signInWithEmail(email, password));
    if (!state.hasError) await _checkOnboarding();
  }

  Future<void> signUpWithEmail(
      String email,
      String password, {
        String? firstName,
        String? lastName,
        int? age,
      }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.signUpWithEmail(
      email,
      password,
      firstName: firstName,
      lastName: lastName,
      age: age,
    ));
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.sendPasswordReset(email));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.signOut());
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.deleteAccount());
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});