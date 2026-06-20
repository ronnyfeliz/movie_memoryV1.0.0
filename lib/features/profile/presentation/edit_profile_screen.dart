import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();
  String _gender = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserRepository().getCurrentUser();
    if (user != null && mounted) {
      _firstNameCtrl.text = user.firstName;
      _lastNameCtrl.text = user.lastName;
      _ageCtrl.text = user.age > 0 ? user.age.toString() : '';
      _bioCtrl.text = user.bio;
      _photoUrlCtrl.text = user.photoURL;
      _gender = user.gender;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _bioCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  void _showAvatarSelector() {
    final cs = Theme.of(context).colorScheme;
    final avatars = [
      'https://api.dicebear.com/7.x/adventurer/png?seed=Aria',
      'https://api.dicebear.com/7.x/adventurer/png?seed=Leo',
      'https://api.dicebear.com/7.x/adventurer/png?seed=Mia',
      'https://api.dicebear.com/7.x/adventurer/png?seed=Jack',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Luna',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Sophia',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Lucas',
      'https://api.dicebear.com/7.x/bottts/png?seed=Robo1',
      'https://api.dicebear.com/7.x/bottts/png?seed=Robo2',
      'https://api.dicebear.com/7.x/lorelei/png?seed=Grace',
      'https://api.dicebear.com/7.x/lorelei/png?seed=Ethan',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerHighest,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Elige un avatar predefinido',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1),
              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, idx) {
                    final avatarUrl = avatars[idx];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _photoUrlCtrl.text = avatarUrl;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _photoUrlCtrl.text == avatarUrl
                                ? cs.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(avatarUrl),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlInputDialog() {
    final controller = TextEditingController(
      text: _photoUrlCtrl.text,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL de imagen de perfil'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://ejemplo.com/imagen.jpg',
            helperText: 'Debe ser una dirección web válida',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isEmpty) {
                Navigator.pop(ctx);
                return;
              }
              final uri = Uri.tryParse(url);
              final isUrl = uri != null && uri.hasAbsolutePath;
              if (!isUrl) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('URL no válida. Debe comenzar con http:// o https://'),
                  backgroundColor: Colors.red,
                ));
                return;
              }
              final path = uri.path.toLowerCase();
              final isImage = path.endsWith('.jpg') ||
                  path.endsWith('.jpeg') ||
                  path.endsWith('.png') ||
                  path.endsWith('.gif') ||
                  path.endsWith('.webp') ||
                  path.endsWith('.bmp') ||
                  url.contains('api.dicebear.com') ||
                  url.contains('picsum.photos') ||
                  url.contains('placeholder');
              if (!isImage) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('La URL debe apuntar a una imagen válida (.jpg, .jpeg, .png, .webp, .gif)'),
                  backgroundColor: Colors.red,
                ));
                return;
              }
              setState(() {
                _photoUrlCtrl.text = url;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerHighest,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.face_rounded),
                title: const Text('Elegir un avatar predefinido'),
                onTap: () {
                  Navigator.pop(context);
                  _showAvatarSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_outlined),
                title: const Text('Introducir URL de imagen'),
                onTap: () {
                  Navigator.pop(context);
                  _showUrlInputDialog();
                },
              ),
              if (_photoUrlCtrl.text.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Eliminar foto actual', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _photoUrlCtrl.text = '';
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveConfirmation),
        content: Text(l10n.saveChangesMessage, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              Navigator.pop(ctx, false);
            },
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playConfirm(prefs);
              Navigator.pop(ctx, true);
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await UserRepository().getCurrentUser();
      if (currentUser == null) throw Exception('User not found');

      String photoUrl = _photoUrlCtrl.text.trim();

      final updated = currentUser.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
        photoURL: photoUrl,
        gender: _gender,
        bio: _bioCtrl.text.trim(),
      );

      await UserRepository().updateUser(updated);
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(l10n.profileUpdated),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String userMessage;
        if (e is FirebaseException && e.plugin == 'storage') {
          if (e.code == 'object-not-found' || (e.message?.contains('404') ?? false)) {
            userMessage = 'Firebase Storage no está configurado. Ve a Firebase Console → Storage → Crear base de datos.';
          } else {
            userMessage = '${l10n.profileUpdateError}: ${e.message}';
          }
        } else {
          userMessage = '${l10n.profileUpdateError}: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(userMessage),
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.save, style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _showPhotoOptions,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: cs.surfaceContainerHigh,
                      backgroundImage: _photoUrlCtrl.text.isNotEmpty
                          ? CachedNetworkImageProvider(_photoUrlCtrl.text)
                          : null,
                      child: _photoUrlCtrl.text.isEmpty
                          ? Icon(Icons.person, size: 64, color: cs.primary)
                          : null,
                    ),
                    if (!_isLoading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildField(l10n.firstName, _firstNameCtrl, required: true),
            const SizedBox(height: 12),
            _buildField(l10n.lastName, _lastNameCtrl, required: true),
            const SizedBox(height: 12),
            _buildField(l10n.age, _ageCtrl, keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 12),
            _buildGenderField(l10n),
            const SizedBox(height: 12),
            _buildField(l10n.bio, _bioCtrl, maxLines: 3),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool required = false, TextInputType? keyboardType, int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: const TextStyle(),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? null : null : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField(AppLocalizations l10n) {
    final options = [
      (l10n.male, 'male'),
      (l10n.female, 'female'),
      (l10n.nonBinary, 'nonBinary'),
      (l10n.preferNotToSay, 'preferNotToSay'),
      (l10n.otherGender, 'other'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.gender, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _gender.isEmpty ? null : _gender,
          dropdownColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
          style: const TextStyle(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : const Color(0xFF1C2236),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          hint: Text(l10n.preferNotToSay, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          items: options.map((o) => DropdownMenuItem(value: o.$2, child: Text(o.$1))).toList(),
          onChanged: (v) => setState(() => _gender = v ?? ''),
        ),
      ],
    );
  }
}
