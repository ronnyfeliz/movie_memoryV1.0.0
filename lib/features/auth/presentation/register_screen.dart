import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import 'auth_provider.dart';
import 'package:movie_memory/core/sound/sound_service.dart';
import 'package:movie_memory/core/sound/sound_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _ageError;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    setState(() {
      _emailError = null;
      _passwordError = null;
      _ageError = null;
    });

    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final ageText = _ageController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || lastName.isEmpty || ageText.isEmpty ||
        email.isEmpty || password.isEmpty || confirm.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.completeAllFields)),
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 18) {
      setState(() => _ageError = l10n.mustBe18);
      return;
    }

    if (password != confirm) {
      setState(() => _passwordError = l10n.passwordsDontMatch);
      return;
    }

    if (password.length < 6) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.minPasswordLength(6.toString()))),
      );
      return;
    }

    ref.read(isRegisteringProvider.notifier).state = true;

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
      email,
      password,
      firstName: name,
      lastName: lastName,
      age: age,
    );

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState.hasError) {
      await SoundService.playError(prefs);
      ref.read(isRegisteringProvider.notifier).state = false;
      final errorMsg = authState.error.toString();
      if (errorMsg.contains('email-already-in-use') ||
          errorMsg.contains('already in use')) {
        setState(() => _emailError = l10n.emailAlreadyInUse);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
      return;
    }

    if (mounted) {
      await SoundService.playConfirm(prefs);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.registrationSuccess,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.confirmationSent,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            SoundService.playConfirm(ref.read(soundPreferencesProvider));
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.accept,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -40,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black87,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        if (!mounted) return;
        await ref.read(authNotifierProvider.notifier).signOut();
        if (!mounted) return;
        ref.read(isRegisteringProvider.notifier).state = false;
        context.go('/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () async {
            final prefs = ref.read(soundPreferencesProvider);
            await SoundService.playClick(prefs);
            if (context.mounted) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.registerTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.registerSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              _buildField(
                controller: _nameController,
                hint: l10n.nameLabel,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _lastNameController,
                hint: l10n.lastNameLabel,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  if (_ageError != null) {
                    setState(() => _ageError = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.age,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _ageError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _ageError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.cake_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  errorText: _ageError,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                style: const TextStyle(),
              ),
              const SizedBox(height: 12),
              // Email con error inline
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.email,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _emailError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _emailError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  errorText: _emailError,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                style: const TextStyle(),
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _passwordController,
                hint: l10n.passwordLabel,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.confirmPassword,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _passwordError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _passwordError != null
                        ? const BorderSide(color: Colors.red, width: 1.5)
                        : BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  errorText: _passwordError,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                style: const TextStyle(),
              ),
              const SizedBox(height: 28),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.createAccount,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () async {
                      final prefs = ref.read(soundPreferencesProvider);
                      await SoundService.playClick(prefs);
                      if (context.mounted) context.pop();
                    },
                    child: Text(
                      l10n.logIn,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      style: const TextStyle(),
    );
  }
}