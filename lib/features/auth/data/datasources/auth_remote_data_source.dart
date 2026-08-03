import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/supabase/supabase_client.dart';
import '../models/change_password_request.dart';
import '../models/change_password_response.dart';
import '../models/login_request.dart';
import '../models/reset_password_request.dart';

// Remote data source untuk memanggil endpoint auth
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  // Login menggunakan Supabase Auth, lalu mengambil profile karyawan.
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final client = AppSupabaseClient.client;
    final response = await client.auth.signInWithPassword(
      email: request.email,
      password: request.password,
    );

    final uid = response.user?.id ?? client.auth.currentUser?.id;
    if (uid == null) {
      throw const supabase.AuthException('Invalid login credentials');
    }

    final data = await client.from('karyawan').select().eq('id', uid).single();

    return Map<String, dynamic>.from(data);
  }

  // Mengambil profile karyawan berdasarkan user id Supabase Auth.
  Future<Map<String, dynamic>> getKaryawanById(String id) async {
    final data = await AppSupabaseClient.client
        .from('karyawan')
        .select()
        .eq('id', id)
        .single();

    return Map<String, dynamic>.from(data);
  }

  // Memanggil endpoint lupa password tanpa Bearer token.
  Future<void> forgotPassword(String email) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/auth/forgot-password',
      data: {'email': email},
      options: Options(extra: const <String, dynamic>{'skipAuth': true}),
    );
  }

  // Memanggil endpoint reset password tanpa Bearer token.
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/auth/reset-password',
      data: request.toJson(),
      options: Options(extra: const <String, dynamic>{'skipAuth': true}),
    );
  }

  // Memanggil endpoint ubah password dengan Bearer token user login.
  Future<ChangePasswordResponse> changePassword(
    ChangePasswordRequest request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/auth/change-password',
      data: request.toJson(),
    );

    return ChangePasswordResponse.fromJson(
      response.data ?? <String, dynamic>{},
    );
  }
}
