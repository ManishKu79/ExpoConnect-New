import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

extension ContextExtensions on BuildContext {
  // Auth
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToForgotPassword() => go(AppRoutes.forgotPassword);
  void goToVerifyEmail() => go(AppRoutes.verifyEmail);
  
  // Main
  void goToHome() => go(AppRoutes.home);
  void goToProfile() => go(AppRoutes.profile);
  
  // Events
  void goToEvents() => go(AppRoutes.events);
  void goToEventDetail(String id) => go('${AppRoutes.eventDetail.replaceFirst(':id', id)}');
  
  // Organizer
  void goToCreateEvent() => go(AppRoutes.createEvent);
  void goToEditEvent(String id) => go('${AppRoutes.editEvent.replaceFirst(':id', id)}');
  void goToMyEvents() => go(AppRoutes.myEvents);
  
  // QR
  void goToQRScanner() => go(AppRoutes.qrScanner);
  
  // Notifications
  void goToNotifications() => go(AppRoutes.notifications);
}