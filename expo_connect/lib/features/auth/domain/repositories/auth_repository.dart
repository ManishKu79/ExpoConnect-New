import '../entities/user.dart';

abstract class AuthRepository {
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
}