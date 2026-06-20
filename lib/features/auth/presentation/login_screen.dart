import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_provider.dart';
import 'package:movie_memory/core/sound/sound_service.dart';
import 'package:movie_memory/core/sound/sound_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    setState(() => _loginError = null);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      setState(() => _loginError = AppLocalizations.of(context)!.googleSignInError);
    }
  }

  Future<void> _signInWithEmail() async {
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    setState(() => _loginError = null);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _loginError = AppLocalizations.of(context)!.fillAllFields);
      return;
    }
    await ref.read(authNotifierProvider.notifier).signInWithEmail(email, password);
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      final errorMsg = authState.error.toString();
      final l10n = AppLocalizations.of(context)!;
      if (errorMsg.contains('verificar')) {
        setState(() => _loginError = l10n.verifyEmailFirst);
      } else if (errorMsg.contains('wrong-password') ||
          errorMsg.contains('user-not-found') ||
          errorMsg.contains('invalid-credential') ||
          errorMsg.contains('INVALID_LOGIN_CREDENTIALS')) {
        setState(() => _loginError = l10n.wrongCredentials);
      } else {
        setState(() => _loginError = l10n.loginError);
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    setState(() => _loginError = null);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _loginError = l10n.enterEmailFirst);
      return;
    }
    await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
    if (mounted) {
      setState(() => _loginError = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(l10n.recoveryEmailSent),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'logo/Logo_MovieMemoryApp.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'MovieMemory',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: isLoading ? null : _signInWithGoogle,
                icon: Icon(Icons.g_mobiledata, color: Theme.of(context).colorScheme.onSurfaceVariant),
                label: Text(
                  l10n.continueWithGoogle,
                  style: const TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(l10n.or, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                onChanged: (_) {
                  if (_loginError != null) setState(() => _loginError = null);
                },
                decoration: InputDecoration(
                  hintText: l10n.emailLabel,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                style: const TextStyle(),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) {
                  if (_loginError != null) setState(() => _loginError = null);
                },
                decoration: InputDecoration(
                  hintText: l10n.passwordLabel,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _loginError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _loginError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  errorText: _loginError,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                style: const TextStyle(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : _sendPasswordReset,
                  child: Text(
                    l10n.forgotPassword,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _signInWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.signIn,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.noAccount,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () async {
                      final prefs = ref.read(soundPreferencesProvider);
                      await SoundService.playClick(prefs);
                      if (!context.mounted) return;
                      context.push('/register');
                    },
                    child: Text(
                      l10n.signUp,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}