import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../shared/services/storage_service.dart';

// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
  );
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// ============ AUTH STATE ============
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// ============ AUTH NOTIFIER ============
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState()) {
    checkAuthStatus();
  }

  // ============ CHECK AUTH STATUS ============
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await StorageService.isLoggedIn();
    print('🔍 checkAuthStatus: isLoggedIn = $isLoggedIn');
    
    if (isLoggedIn) {
      try {
        final user = await repository.getCurrentUser();
        print('✅ Auth check successful, user: ${user.email}');
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          error: null,
        );
      } catch (e) {
        print('❌ Auth check failed: $e');
        await StorageService.clearAll();
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
        );
      }
    } else {
      print('ℹ️ No token found, user not authenticated');
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
      );
    }
  }

  // ============ LOGIN ============
  Future<void> login(String email, String password) async {
    print('🔐 Login started for: $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.login(email, password);
      print('✅ Login successful for: ${user.email}');
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      print('❌ Login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ============ REGISTER ============
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    print('📝 Registration started for: $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      print('✅ Registration successful for: ${user.email}');
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      print('❌ Registration error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ============ VERIFY EMAIL ============
  Future<void> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.verifyEmail(token);
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ============ FORGOT PASSWORD ============
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.forgotPassword(email);
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ============ RESET PASSWORD ============
  Future<void> resetPassword(String token, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.resetPassword(token, password);
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ============ GET CURRENT USER ============
  Future<User?> getCurrentUser() async {
    try {
      final user = await repository.getCurrentUser();
      return user;
    } catch (e) {
      print('❌ Get current user error: $e');
      return null;
    }
  }

  // ============ LOGOUT ============
  Future<void> logout() async {
    print('👋 Logging out...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.logout();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    } finally {
      // Clear state and storage
      await StorageService.clearAll();
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      );
      print('✅ State reset - isAuthenticated: ${state.isAuthenticated}');
    }
  }

  // ============ UPDATE PROFILE ============
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    List<String>? interests,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = state.user;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      final updatedUser = await repository.updateProfile(
        userId: user.id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
        interests: interests,
      );
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      print('❌ Update profile error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // ============ CHANGE PASSWORD ============
  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.changePassword(currentPassword, newPassword);
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      print('❌ Change password error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // ============ DELETE ACCOUNT ============
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = state.user;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      await repository.deleteAccount(user.id);
      await logout();
    } catch (e) {
      print('❌ Delete account error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // ============ CLEAR ERROR ============
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ============ REFRESH USER ============
  Future<void> refreshUser() async {
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          error: null,
        );
      }
    } catch (e) {
      print('❌ Refresh user error: $e');
    }
  }

  // ============ IS LOGGED IN ============
  Future<bool> isLoggedIn() async {
    return await repository.isLoggedIn();
  }
}