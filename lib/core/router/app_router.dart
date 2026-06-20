import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../sound/sound_provider.dart';
import '../sound/sound_service.dart';

import '../../../l10n/app_localizations.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/discover/presentation/category_detail_screen.dart';
import '../../features/discover/presentation/advanced_discover_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/library/presentation/public_lists_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/search/presentation/detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/notifications/presentation/notification_settings_screen.dart';

final isRegisteringProvider = StateProvider<bool>((ref) => false);

final _routerRefreshNotifier = ValueNotifier<int>(0);

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authStateProvider, (_, __) {
    _routerRefreshNotifier.value++;
  });
  ref.listen(isRegisteringProvider, (_, __) {
    _routerRefreshNotifier.value++;
  });
  ref.listen(onboardingRequiredProvider, (_, __) {
    _routerRefreshNotifier.value++;
  });

  Page<T> buildPageWithTransition<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _routerRefreshNotifier,
    redirect: (context, state) {
      final isRegistering = ref.read(isRegisteringProvider);
      if (isRegistering) return null;

      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull ?? false;
      final location = state.matchedLocation;
      final isLoginRoute = location == '/login';
      final isRegisterRoute = location == '/register';
      final isVerifyRoute = location == '/verify-email';
      final isDetailRoute = location.startsWith('/detail/');
      final isOnboardingRoute = location == '/onboarding';

      if (!isLoggedIn && isLoginRoute) return null;
      if (isLoggedIn && isLoginRoute && !isOnboardingRoute) {
        final needsOnboarding = ref.read(onboardingRequiredProvider);
        if (needsOnboarding) return '/onboarding';
        return '/discover';
      }
      if (isRegisterRoute || isVerifyRoute || isDetailRoute || isOnboardingRoute) return null;
      if (!isLoggedIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithTransition(const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => buildPageWithTransition(const RegisterScreen()),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => buildPageWithTransition(VerifyEmailScreen(
          email: state.extra as String,
        )),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildPageWithTransition(const OnboardingScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => buildPageWithTransition(const NotificationsScreen()),
      ),
      GoRoute(
        path: '/notification-settings',
        pageBuilder: (context, state) => buildPageWithTransition(const NotificationSettingsScreen()),
      ),
      GoRoute(
        path: '/discover/category',
        pageBuilder: (context, state) {
          final key = state.uri.queryParameters['key'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          return buildPageWithTransition(CategoryDetailScreen(categoryKey: key, title: title));
        },
      ),
      GoRoute(
        path: '/discover/advanced',
        pageBuilder: (context, state) => buildPageWithTransition(const AdvancedDiscoverScreen()),
      ),
      GoRoute(
        path: '/detail/:tmdbId',
        pageBuilder: (context, state) {
          final tmdbId = int.parse(state.pathParameters['tmdbId']!);
          final type = state.uri.queryParameters['type'] ?? 'movie';
          return buildPageWithTransition(DetailScreen(tmdbId: tmdbId, mediaType: type));
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/lists',
            builder: (context, state) => const PublicListsScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static bool _openAppSoundPlayed = false;

  int _locationToIndex(String location) {
    if (location.startsWith('/discover')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/lists')) return 2;
    if (location.startsWith('/library')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 600;

    if (!_openAppSoundPlayed) {
      _openAppSoundPlayed = true;
      final isLoggedIn = ref.read(authStateProvider).valueOrNull ?? false;
      if (isLoggedIn) {
        final prefs = ref.read(soundPreferencesProvider);
        SoundService.playOpenApp(prefs);
      }
    }

    final destinations = [
      (
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore,
        label: AppLocalizations.of(context)!.discover
      ),
      (
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: AppLocalizations.of(context)!.search
      ),
      (
        icon: Icons.format_list_bulleted_outlined,
        selectedIcon: Icons.format_list_bulleted,
        label: AppLocalizations.of(context)!.listsNav
      ),
      (
        icon: Icons.video_library_outlined,
        selectedIcon: Icons.video_library,
        label: AppLocalizations.of(context)!.library
      ),
      (
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: AppLocalizations.of(context)!.profile
      ),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              elevation: 4,
              backgroundColor: cs.surface,
              indicatorColor: cs.primary.withValues(alpha: 0.15),
              onDestinationSelected: (index) {
                final prefs = ref.read(soundPreferencesProvider);
                SoundService.playClick(prefs);
                _onNavigate(context, index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: destinations.map((d) => NavigationRailDestination(
                icon: Icon(d.icon, color: cs.onSurfaceVariant),
                selectedIcon: Icon(d.selectedIcon, color: cs.primary),
                label: Text(
                  d.label,
                  style: const TextStyle(
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: NavigationBar(
            backgroundColor: cs.surface.withValues(alpha: 0.65),
            elevation: 0,
            indicatorColor: cs.primary.withValues(alpha: 0.15),
            selectedIndex: currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              _onNavigate(context, index);
            },
            destinations: destinations.map((d) => NavigationDestination(
              icon: Icon(d.icon, color: cs.onSurfaceVariant),
              selectedIcon: Icon(d.selectedIcon, color: cs.primary),
              label: d.label,
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _onNavigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/discover');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/lists');
        break;
      case 3:
        context.go('/library');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}