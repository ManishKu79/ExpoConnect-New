import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/services/api_service.dart';

class AuthRemoteDataSource {
  final Dio dio = ApiService.dio;
  final Logger _logger = Logger();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = {
      'email': email.toLowerCase(),
      'password': password,
    };
    
    _logger.i('📝 Login data: $data');
    
    final response = await dio.post(
      ApiEndpoints.login,
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    final data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email.toLowerCase(),
      'password': password,
    };
    
    if (phone != null && phone.isNotEmpty) {
      data['phone'] = phone;
    }
    if (role != null && role.isNotEmpty) {
      data['role'] = role;
    }
    
    _logger.i('📝 Register data: ${jsonEncode(data)}');
    
    final response = await dio.post(
      ApiEndpoints.register,
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await dio.post(
      ApiEndpoints.verifyEmail,
      data: {'token': token},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.toLowerCase()},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    final response = await dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'password': password,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await dio.get(ApiEndpoints.me);
    return response.data;
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await dio.post(ApiEndpoints.logout);
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await dio.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    List<String>? interests,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (interests != null) data['interests'] = interests;
    
    final response = await dio.put(
      '${ApiEndpoints.users}/$userId',
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final response = await dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteAccount(String userId) async {
    final response = await dio.delete(
      '${ApiEndpoints.users}/$userId',
    );
    return response.data;
  }
}