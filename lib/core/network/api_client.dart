import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../supabase/supabase_client.dart';

class ApiClient {
  ApiClient._();

  static Future<void> Function(String message)? onAccountInactive;
  static bool _isHandlingAccountInactive = false;

  static final Dio dio = _createDio();

  static void resetAccountInactiveHandling() {
    _isHandlingAccountInactive = false;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        // API BASE DIO BELOM
        baseUrl: dotenv.env['API_BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra['skipAuth'] == true) {
            handler.next(options);
            return;
          }

          final accessToken =
              AppSupabaseClient.client.auth.currentSession?.accessToken;

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (_isAccountInactiveError(error)) {
            await _handleAccountInactive(error);
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static bool _isAccountInactiveError(DioException error) {
    if (error.requestOptions.extra['skipAuth'] == true) return false;
    if (error.response?.statusCode != 403) return false;

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return data['code']?.toString() == 'ACCOUNT_INACTIVE';
    }
    if (data is Map) {
      return data['code']?.toString() == 'ACCOUNT_INACTIVE';
    }

    return false;
  }

  static Future<void> _handleAccountInactive(DioException error) async {
    if (_isHandlingAccountInactive) return;

    _isHandlingAccountInactive = true;
    final data = error.response?.data;
    final message = data is Map ? data['message']?.toString().trim() : null;

    await onAccountInactive?.call(
      message == null || message.isEmpty
          ? 'Akun Anda sudah tidak aktif. Silakan hubungi administrator.'
          : message,
    );
  }
}
