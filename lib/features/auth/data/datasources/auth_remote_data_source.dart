import 'package:dio/dio.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';

// Remote data source untuk memanggil endpoint auth
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  // Memanggil endpoint login
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: request.toJson(),
    );

    return LoginResponse.fromJson(response.data ?? <String, dynamic>{});
  }

  // Memanggil endpoint lupa password
  Future<void> forgotPassword(String email) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/auth/forgot-password',
      data: {'email': email},
    );
  }
}
