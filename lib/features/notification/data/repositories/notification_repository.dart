import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/notification_remote_data_source.dart';
import '../models/notification_response_model.dart';

class NotificationRepository {
  const NotificationRepository(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  Future<List<NotificationResponseModel>> getNotifications() async {
    try {
      final response = await _remoteDataSource.getNotifications();
      return _mapNotificationResponse(response);
    } on NotificationException {
      rethrow;
    } on DioException catch (error) {
      throw NotificationException(
        _mapDioError(
          error,
          timeoutMessage: 'Request notifikasi melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil notifikasi.',
        ),
      );
    } on SocketException {
      throw const NotificationException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Notification unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const NotificationException('Gagal mengambil notifikasi.');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _remoteDataSource.getUnreadCount();
      return _mapUnreadCountResponse(response);
    } on NotificationException {
      rethrow;
    } on DioException catch (error) {
      throw NotificationException(
        _mapDioError(
          error,
          timeoutMessage: 'Request jumlah notifikasi melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil jumlah notifikasi.',
        ),
      );
    } on SocketException {
      throw const NotificationException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Notification unread unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const NotificationException('Gagal mengambil jumlah notifikasi.');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _remoteDataSource.markAsRead(notificationId);
      if (response['success'] != true) {
        throw NotificationException(_readApiMessage(response));
      }
    } on NotificationException {
      rethrow;
    } on DioException catch (error) {
      throw NotificationException(
        _mapDioError(
          error,
          timeoutMessage: 'Request baca notifikasi melebihi batas waktu.',
          fallbackMessage: 'Gagal menandai notifikasi sebagai dibaca.',
        ),
      );
    } on SocketException {
      throw const NotificationException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Notification read unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const NotificationException(
        'Gagal menandai notifikasi sebagai dibaca.',
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _remoteDataSource.markAllAsRead();
      if (response['success'] != true) {
        throw NotificationException(_readApiMessage(response));
      }
    } on NotificationException {
      rethrow;
    } on DioException catch (error) {
      throw NotificationException(
        _mapDioError(
          error,
          timeoutMessage: 'Request baca semua notifikasi melebihi batas waktu.',
          fallbackMessage: 'Gagal menandai semua notifikasi sebagai dibaca.',
        ),
      );
    } on SocketException {
      throw const NotificationException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Notification read-all unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const NotificationException(
        'Gagal menandai semua notifikasi sebagai dibaca.',
      );
    }
  }

  List<NotificationResponseModel> _mapNotificationResponse(
    Map<String, dynamic> response,
  ) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;

    if (isSuccess && rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) => NotificationResponseModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (isSuccess && rawItems == null) return const [];

    throw NotificationException(_readApiMessage(response));
  }

  int _mapUnreadCountResponse(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];

    if (!isSuccess) {
      throw NotificationException(_readApiMessage(response));
    }

    final rawCount = rawData is Map
        ? rawData['unread_count'] ??
              rawData['unread'] ??
              rawData['count'] ??
              rawData['total']
        : rawData;

    if (rawCount is int) return rawCount;
    if (rawCount is num) return rawCount.toInt();

    final parsed = int.tryParse(rawCount?.toString() ?? '');
    return parsed ?? 0;
  }

  String _readApiMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return 'Gagal mengambil notifikasi.';
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

class NotificationException implements Exception {
  const NotificationException(this.message);

  final String message;

  @override
  String toString() => message;
}
