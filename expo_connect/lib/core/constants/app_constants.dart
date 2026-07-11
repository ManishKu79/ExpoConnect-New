class AppConstants {
  static const String appName = 'ExpoConnect';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Next Generation Business Expo Management Platform';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;

  // Pagination
  static const int defaultPageSize = 10;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}