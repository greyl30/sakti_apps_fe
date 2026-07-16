import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/supabase/supabase_client.dart';
import '../models/login_request.dart';

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

  // Memanggil endpoint lupa password
  Future<void> forgotPassword(String email) async {
    // TODO(Supabase):
    // Migrasikan forgot password ke Supabase Auth pada sprint berikutnya.
    await _dio.post<Map<String, dynamic>>(
      '/api/auth/forgot-password',
      data: {'email': email},
    );
  }
}
