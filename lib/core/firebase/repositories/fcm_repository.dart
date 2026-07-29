import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/fcm_remote_data_source.dart';
import '../models/fcm_token_registration_request.dart';

class FcmRepository {
  const FcmRepository(this._remoteDataSource);

  final FcmRemoteDataSource _remoteDataSource;

  Future<void> registerToken(FcmTokenRegistrationRequest request) async {
    try {
      debugPrint('FCM register request: POST /api/fcm/register');
      debugPrint('FCM register body: ${request.toJson()}');
      final response = await _remoteDataSource.registerToken(request);
      if (response['success'] == true) return;

      throw FcmRegistrationException(_readApiMessage(response));
    } on FcmRegistrationException {
      rethrow;
    } on DioException catch (error) {
      throw FcmRegistrationException(_mapDioError(error));
    } on SocketException {
      throw const FcmRegistrationException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const FcmRegistrationException('Gagal menyimpan FCM token.');
    }
  }

  String _readApiMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return 'Gagal menyimpan FCM token.';
  }

  String _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Request registrasi FCM token melebihi batas waktu.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return 'Tidak dapat terhubung ke server.';
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return '$message (status: ${error.response?.statusCode}, response: $responseData)';
      }
      return 'Gagal menyimpan FCM token. (status: ${error.response?.statusCode}, response: $responseData)';
    }

    if (responseData != null) {
      return 'Gagal menyimpan FCM token. (status: ${error.response?.statusCode}, response: $responseData)';
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang tidak tersedia.';
    }

    return 'Gagal menyimpan FCM token.';
  }
}

class FcmRegistrationException implements Exception {
  const FcmRegistrationException(this.message);

  final String message;

  @override
  String toString() => message;
}
