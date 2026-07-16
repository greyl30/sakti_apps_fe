import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

// Repository untuk komunikasi data auth
class AuthRepository {
  const AuthRepository(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  // Request login, menyimpan token, dan menyimpan data user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userJson = await _remoteDataSource.login(
        LoginRequest(email: email, password: password),
      );

      final user = UserModel.fromJson(userJson);
      final accessToken =
          AppSupabaseClient.client.auth.currentSession?.accessToken;

      if (accessToken != null) {
        // Menyimpan access token ke secure storage
        await SecureStorageService.saveToken(accessToken);
      }

      // Menyimpan data user ke secure storage untuk dipakai ulang
      await SecureStorageService.saveUser(jsonEncode(user.toJson()));

      return user;
    } on supabase.AuthException catch (error) {
      throw AuthException(_mapSupabaseAuthError(error));
    } on SocketException {
      throw const AuthException('Tidak dapat terhubung ke server.');
    } on DioException catch (error) {
      throw AuthException(_mapDioError(error));
    } catch (error) {
      throw AuthException(_mapLoginError(error));
    }
  }

  // Request link reset password ke backend
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
    } on DioException catch (error) {
      throw AuthException(_mapDioError(error));
    }
  }

  // Error handling dikelola di repository agar UI tetap sederhana
  String _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Permintaan melebihi batas waktu.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang tidak tersedia.';
    }

    return 'Email atau password salah';
  }

  String _mapSupabaseAuthError(supabase.AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login') ||
        message.contains('invalid credentials') ||
        message.contains('invalid_credentials')) {
      return 'Email atau password salah';
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Tidak dapat terhubung ke server.';
    }

    return 'Terjadi kesalahan saat login. Silakan coba lagi.';
  }

  String _mapLoginError(Object error) {
    final message = error.toString().toLowerCase();
    final type = error.runtimeType.toString().toLowerCase();

    if (message.contains('invalid login') ||
        message.contains('invalid credentials') ||
        message.contains('invalid_credentials')) {
      return 'Email atau password salah';
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection') ||
        type.contains('clientexception')) {
      return 'Tidak dapat terhubung ke server.';
    }

    return 'Terjadi kesalahan saat login. Silakan coba lagi.';
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
