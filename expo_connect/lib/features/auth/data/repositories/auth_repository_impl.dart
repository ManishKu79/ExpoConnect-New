import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../shared/services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      print('📝 Login response: $response');
      
      final data = response['data'];
      if (data == null) {
        throw Exception('No data in response');
      }
      
      final userData = data['user'];
      if (userData == null) {
        throw Exception('No user data in response');
      }
      
      final token = data['token'];
      final refreshToken = data['refreshToken'];
      
      if (token != null) {
        await StorageService.saveToken(token);
      }
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Login repository error: $e');
      rethrow;
    }
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    try {
      final response = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      print('📝 Register response: $response');
      
      final data = response['data'];
      if (data == null) {
        throw Exception('No data in response');
      }
      
      final userData = data['user'];
      if (userData == null) {
        throw Exception('No user data in response');
      }
      
      final token = data['token'];
      final refreshToken = data['refreshToken'];
      
      if (token != null) {
        await StorageService.saveToken(token);
      }
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ Register repository error: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    await remoteDataSource.verifyEmail(token);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    await remoteDataSource.resetPassword(token, password);
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await remoteDataSource.getCurrentUser();
      final data = response['data'];
      if (data == null) {
        throw Exception('No data in response');
      }
      return UserModel.fromJson(data);
    } catch (e) {
      print('❌ Get current user error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    print('👋 Logging out...');
    try {
      await remoteDataSource.logout();
      print('✅ Logout API call successful');
    } catch (e) {
      print('❌ Logout API error: $e');
    } finally {
      // Always clear local storage regardless of API response
      await StorageService.clearAll();
      print('✅ Local storage cleared');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  @override
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    List<String>? interests,
  }) async {
    try {
      final response = await remoteDataSource.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
        interests: interests,
      );
      final data = response['data'];
      if (data == null) {
        throw Exception('No data in response');
      }
      return UserModel.fromJson(data);
    } catch (e) {
      print('❌ Update profile error: $e');
      rethrow;
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
    } catch (e) {
      print('❌ Change password error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      await remoteDataSource.deleteAccount(userId);
    } catch (e) {
      print('❌ Delete account error: $e');
      rethrow;
    }
  }
}