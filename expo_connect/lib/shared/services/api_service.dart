import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  static final Logger _logger = Logger();

  static Dio get dio {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Don't throw on non-2xx status codes - handle them manually
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.i('${options.method} ${options.path}');
          if (options.data != null) {
            _logger.d('Request data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('Response: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('Error: ${error.message}');
          if (error.response != null) {
            _logger.e('Error response: ${error.response?.data}');
          }
          
          // Handle token refresh
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = await StorageService.getRefreshToken();
              if (refreshToken != null) {
                final response = await _dio.post(
                  ApiEndpoints.refreshToken,
                  data: {'refreshToken': refreshToken},
                );
                if (response.statusCode == 200) {
                  final data = response.data['data'];
                  await StorageService.saveToken(data['token']);
                  await StorageService.saveRefreshToken(data['refreshToken']);
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: {
                      'Authorization': 'Bearer ${data['token']}',
                    },
                  );
                  final retryResponse = await _dio.request(
                    error.requestOptions.path,
                    options: opts,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );
                  return handler.resolve(retryResponse);
                }
              }
            } catch (e) {
              _logger.e('Token refresh failed: $e');
              await StorageService.clearAll();
            }
          }
          return handler.next(error);
        },
      ),
    );

    return _dio;
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }
}