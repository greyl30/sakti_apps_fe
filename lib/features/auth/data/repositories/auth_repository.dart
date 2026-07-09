import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

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
      final response = await _remoteDataSource.login(
        LoginRequest(email: email, password: password),
      );

      final loginData = response.data;
      if (!response.success || loginData == null) {
        throw const AuthException('Email atau password salah');
      }

      // Menyimpan access token ke secure storage
      await SecureStorageService.saveToken(loginData.accessToken);

      // Menyimpan data user ke secure storage untuk dipakai ulang
      await SecureStorageService.saveUser(jsonEncode(loginData.user.toJson()));

      return loginData.user;
    } on DioException catch (error) {
      throw AuthException(_mapDioError(error));
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
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
