import '../entities/user.dart';

abstract class AuthRepository {
  // Auth methods
  Future<User> login(String email, String password);
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? role,
  });
  Future<void> verifyEmail(String token);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String password);
  Future<User> getCurrentUser();
  Future<void> logout();
  Future<bool> isLoggedIn();
  
  // Profile methods
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    List<String>? interests,
  });
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String userId);
}