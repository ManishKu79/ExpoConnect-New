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
import '../../features/home/presentation/screens/admin_home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/events/presentation/screens/event_list_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/edit_event_screen.dart';
import '../../features/events/presentation/screens/my_registered_events_screen.dart';
import '../../features/events/presentation/screens/event_entry_qr_screen.dart';
import '../../features/qr/presentation/screens/qr_scanner_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/analytics/presentation/screens/event_analytics_detail_screen.dart';
import '../../features/leads/presentation/screens/lead_list_screen.dart';
import '../../features/leads/presentation/screens/lead_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_events_screen.dart';
import '../../features/admin/presentation/screens/admin_leads_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Helper to get the correct home screen based on role
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
        return const AdminHomeScreen();
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
      
      // List of routes that don't require authentication
      final publicRoutes = ['/login', '/register', '/forgot-password', '/verify-email', '/splash'];
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuth && !isPublicRoute) {
        print('🔴 Redirecting to login - not authenticated');
        return '/login';
      }

      // If authenticated and trying to access public route, redirect to home
      if (isAuth && isPublicRoute && state.matchedLocation != '/splash') {
        print('🟢 Redirecting to home - already authenticated');
        return '/';
      }

      return null;
    },
    routes: [
      // ============ SPLASH ============
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // ============ AUTH ROUTES ============
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
      
      // ============ MAIN ROUTES ============
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
      
      // ============ EVENT ROUTES ============
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
          return EventDetailScreen(eventId: id);
        },
      ),
      
      // ============ ORGANIZER ROUTES ============
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
      
      // ============ VISITOR REGISTRATION ROUTES ============
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
          return EventEntryQRScreen(eventId: id);
        },
      ),
      
      // ============ QR SCANNER ============
      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      
      // ============ NOTIFICATIONS ============
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // ============ ANALYTICS ROUTES ============
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/event-analytics/:id',
        name: 'event-analytics',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventAnalyticsDetailScreen(eventId: id);
        },
      ),
      
      // ============ LEADS ROUTES ============
      GoRoute(
        path: '/leads',
        name: 'leads',
        builder: (context, state) => const LeadListScreen(),
      ),
      GoRoute(
        path: '/leads/:id',
        name: 'lead-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LeadDetailScreen(leadId: id);
        },
      ),
      
      // ============ ADMIN ROUTES ============
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/events',
        name: 'admin-events',
        builder: (context, state) => const AdminEventsScreen(),
      ),
      GoRoute(
        path: '/admin/leads',
        name: 'admin-leads',
        builder: (context, state) => const AdminLeadsScreen(),
      ),
    ],
  );
});

// ============ ROUTE CONSTANTS ============
class AppRoutes {
  // Splash
  static const String splash = '/splash';
  
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  
  // Main
  static const String home = '/';
  static const String profile = '/profile';
  
  // Events
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  
  // Organizer
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event/:id';
  
  // Visitor
  static const String myEvents = '/my-events';
  static const String eventEntry = '/event-entry/:id';
  
  // QR
  static const String qrScanner = '/qr-scanner';
  
  // Notifications
  static const String notifications = '/notifications';
  
  // Analytics
  static const String analytics = '/analytics';
  static const String eventAnalytics = '/event-analytics/:id';
  
  // Leads
  static const String leads = '/leads';
  static const String leadDetail = '/leads/:id';
  
  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminEvents = '/admin/events';
  static const String adminLeads = '/admin/leads';
}