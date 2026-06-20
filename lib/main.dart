import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/l10n/locale_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/cache/tmdb_cache.dart';
import 'core/sound/sound_provider.dart';
import 'core/notification/notification_provider.dart';
import 'core/notification/notification_service.dart';
import 'features/notifications/data/fcm_service.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/player/app_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final tmdbCache = TmdbCache();
  await tmdbCache.init();
  await tmdbCache.deleteByPrefix('en-US:');
  await tmdbCache.deleteByPrefix('es-ES:');
  await tmdbCache.deleteByPrefix('pt-BR:');
  await tmdbCache.deleteByPrefix('it-IT:');
  await tmdbCache.deleteByPrefix('fr-FR:');
  await tmdbCache.deleteByPrefix('ru-RU:');
  await tmdbCache.deleteByPrefix('ko-KR:');
  await tmdbCache.deleteByPrefix('ja-JP:');
  await tmdbCache.deleteByPrefix('zh-CN:');
  final prefs = await SharedPreferences.getInstance();
  AudioCache.instance.prefix = '';
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MovieMemoryApp(),
  ));
}

class MovieMemoryApp extends ConsumerStatefulWidget {
  const MovieMemoryApp({super.key});

  @override
  ConsumerState<MovieMemoryApp> createState() => _MovieMemoryAppState();
}

class _MovieMemoryAppState extends ConsumerState<MovieMemoryApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.wait([
      ref.read(localeProvider.notifier).loadSavedLocale(),
      ref.read(themeProvider.notifier).loadSavedTheme(),
      ref.read(soundPreferencesProvider.notifier).load(),
      ref.read(notificationPreferencesProvider.notifier).load(),
    ]);

    await NotificationService.init();
    final fcm = FcmService();
    await fcm.requestPermission();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await fcm.saveTokenToFirestore(uid);
    }
    fcm.onTokenRefresh().listen((_) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await fcm.saveTokenToFirestore(uid);
      }
    });
    fcm.onForegroundMessage.listen((message) {
      final title = message.notification?.title ?? message.data['title'] ?? '';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      if (title.isNotEmpty && body.isNotEmpty) {
        NotificationService.showCategoryNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          body: body,
          channelId: 'movie_memory_${message.data['category'] ?? 'general'}',
          channelName: message.data['categoryName'] ?? 'MovieMemory',
        );
      }
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (mounted) setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'MovieMemory',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('es'), Locale('en'), Locale('pt'), Locale('it'),
        Locale('fr'), Locale('ru'), Locale('ko'), Locale('ja'), Locale('zh'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: switch (themeMode) {
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
        AppTheme.system => ThemeMode.system,
      },
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: router,
      builder: (context, child) {
        if (!_initialized) {
          return const SplashScreen();
        }
        return child!;
      },
    );
  }
}

ThemeData _buildLightTheme() {
  const primary = Color(0xFF0066FF);
  const scheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE6F0FF),
    onPrimaryContainer: primary,
    secondary: primary,
    surface: Color(0xFFF9F9F9),
    onSurface: Color(0xFF141414),
    onSurfaceVariant: Color(0xFF6B6B6B),
    surfaceContainerHighest: Colors.white,
    surfaceContainerHigh: Color(0xFFF3F3F3),
    outline: Color(0xFFE0E0E0),
    outlineVariant: Color(0xFFEEEEEE),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12),
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return scheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary.withValues(alpha: 0.5);
        return scheme.outline;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const IconThemeData(color: primary);
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: scheme.onSurfaceVariant, fontSize: 12);
      }),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF141414)),
      bodyMedium: TextStyle(color: Color(0xFF141414)),
      bodySmall: TextStyle(color: Color(0xFF6B6B6B)),
      labelLarge: TextStyle(color: Color(0xFF141414)),
    ),
  );
}

ThemeData _buildDarkTheme() {
  const primary = Color(0xFF0066FF);
  const bg = Color(0xFF050811);
  const card = Color(0xFF0F1424);
  const scheme = ColorScheme.dark(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0x330066FF),
    onPrimaryContainer: primary,
    secondary: primary,
    surface: bg,
    onSurface: Colors.white,
    onSurfaceVariant: Color(0xFFB0B0B0),
    surfaceContainerHighest: card,
    surfaceContainerHigh: bg,
    outline: Color(0xFF1B233D),
    outlineVariant: Color(0xFF12182B),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bg,
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: card,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      selectedColor: const Color(0x330066FF),
      side: const BorderSide(color: Colors.white24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return Colors.white54;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary.withValues(alpha: 0.5);
        return Colors.white24;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: card,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: const Color(0x330066FF),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const IconThemeData(color: primary);
        return const IconThemeData(color: Colors.white54);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: Colors.white54, fontSize: 12);
      }),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white54),
      labelLarge: TextStyle(color: Colors.white),
    ),
  );
}
