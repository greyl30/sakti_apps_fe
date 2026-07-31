import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/telegram_remote_data_source.dart';
import '../models/telegram_connect_request.dart';
import '../models/telegram_status_model.dart';

class TelegramRepository {
  const TelegramRepository(this._remoteDataSource);

  final TelegramRemoteDataSource _remoteDataSource;

  Future<TelegramStatusModel> getStatus() async {
    try {
      final response = await _remoteDataSource.getStatus();
      return _mapStatusResponse(response);
    } on TelegramException {
      rethrow;
    } on DioException catch (error) {
      throw TelegramException(
        _mapDioError(
          error,
          timeoutMessage: 'Request status Telegram melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil status Telegram.',
        ),
      );
    } on SocketException {
      throw const TelegramException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Telegram status unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const TelegramException('Gagal mengambil status Telegram.');
    }
  }

  Future<void> connect(String verificationCode) async {
    try {
      final response = await _remoteDataSource.connect(
        TelegramConnectRequest(verificationCode: verificationCode),
      );
      _ensureSuccess(response);
    } on TelegramException {
      rethrow;
    } on DioException catch (error) {
      throw TelegramException(
        _mapDioError(
          error,
          timeoutMessage: 'Request koneksi Telegram melebihi batas waktu.',
          fallbackMessage: 'Gagal menghubungkan Telegram.',
        ),
      );
    } on SocketException {
      throw const TelegramException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Telegram connect unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const TelegramException('Gagal menghubungkan Telegram.');
    }
  }

  Future<void> disconnect() async {
    try {
      final response = await _remoteDataSource.disconnect();
      _ensureSuccess(response);
    } on TelegramException {
      rethrow;
    } on DioException catch (error) {
      throw TelegramException(
        _mapDioError(
          error,
          timeoutMessage:
              'Request putus koneksi Telegram melebihi batas waktu.',
          fallbackMessage: 'Gagal memutuskan koneksi Telegram.',
        ),
      );
    } on SocketException {
      throw const TelegramException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Telegram disconnect unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const TelegramException('Gagal memutuskan koneksi Telegram.');
    }
  }

  TelegramStatusModel _mapStatusResponse(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];

    if (isSuccess && rawData is Map<String, dynamic>) {
      return TelegramStatusModel.fromJson(rawData);
    }

    if (isSuccess && rawData is Map) {
      return TelegramStatusModel.fromJson(Map<String, dynamic>.from(rawData));
    }

    throw TelegramException(_readApiMessage(response));
  }

  void _ensureSuccess(Map<String, dynamic> response) {
    if (response['success'] == true) return;
    throw TelegramException(_readApiMessage(response));
  }

  String _readApiMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return 'Request Telegram gagal diproses.';
  }

  String _mapDioError(
    DioException error, {
    required String timeoutMessage,
    required String fallbackMessage,
  }) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return timeoutMessage;
    }

    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return 'Tidak dapat terhubung ke server.';
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang tidak tersedia.';
    }

    return fallbackMessage;
  }
}

class TelegramException implements Exception {
  const TelegramException(this.message);

  final String message;

  @override
  String toString() => message;
}
