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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState()) {
    checkAuthStatus();
  }

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
      print('📢 State updated: isAuthenticated = true');
    } catch (e) {
      print('❌ Login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

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

  Future<void> logout() async {
    await repository.logout();
    state = state.copyWith(
      user: null,
      isAuthenticated: false,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}