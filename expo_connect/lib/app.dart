import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class ExpoConnectApp extends ConsumerWidget {
  const ExpoConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authStateProvider);

    // Listen to auth state changes and navigate accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authState.isAuthenticated) {
        // If not authenticated, navigate to login
        print('🔴 Not authenticated, redirecting to login');
        GoRouter.of(context).go('/login');
      }
    });

    return MaterialApp.router(
      title: 'ExpoConnect',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}