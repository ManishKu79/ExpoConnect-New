import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/visitor_home_screen.dart';
import '../../features/home/presentation/screens/exhibitor_home_screen.dart';
import '../../features/home/presentation/screens/organizer_home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/events/presentation/screens/event_list_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/edit_event_screen.dart';
import '../../features/events/presentation/screens/my_registered_events_screen.dart';
import '../../features/events/presentation/screens/event_entry_qr_screen.dart';
import '../../features/qr/presentation/screens/qr_scanner_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  Widget getHomeScreen(BuildContext context) {
    final authState = ref.read(authStateProvider);
    final user = authState.user;
    
    if (user == null) {
      return const LoginScreen();
    }
    
    switch (user.role) {
      case 'visitor':
        return const VisitorHomeScreen();
      case 'exhibitor':
        return const ExhibitorHomeScreen();
      case 'organizer':
        return const OrganizerHomeScreen();
      case 'admin':
        return const OrganizerHomeScreen();
      default:
        return const VisitorHomeScreen();
    }
  }

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.contains('/login') ||
          state.matchedLocation.contains('/register') ||
          state.matchedLocation.contains('/forgot-password') ||
          state.matchedLocation.contains('/verify-email') ||
          state.matchedLocation.contains('/splash');

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }
      if (isAuth && isAuthRoute && state.matchedLocation != '/splash') {
        return '/';
      }
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      
      // Main
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => getHomeScreen(context),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Events
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventListScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        name: 'event-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          print('🔍 Navigating to event detail with ID: $id');
          return EventDetailScreen(eventId: id);
        },
      ),
      
      // Organizer
      GoRoute(
        path: '/create-event',
        name: 'create-event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/edit-event/:id',
        name: 'edit-event',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditEventScreen(eventId: id);
        },
      ),
      
      // Visitor Registration
      GoRoute(
        path: '/my-events',
        name: 'my-events',
        builder: (context, state) => const MyRegisteredEventsScreen(),
      ),
      GoRoute(
        path: '/event-entry/:id',
        name: 'event-entry',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          print('🔍 Navigating to event-entry with ID: $id');
          return EventEntryQRScreen(eventId: id);
        },
      ),
      
      // QR Scanner
      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String home = '/';
  static const String profile = '/profile';
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event/:id';
  static const String myEvents = '/my-events';
  static const String eventEntry = '/event-entry/:id';
  static const String qrScanner = '/qr-scanner';
  static const String notifications = '/notifications';
}