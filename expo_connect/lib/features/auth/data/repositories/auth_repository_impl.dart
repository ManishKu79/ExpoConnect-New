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
    try {
      await remoteDataSource.logout();
    } finally {
      await StorageService.clearAll();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }
}