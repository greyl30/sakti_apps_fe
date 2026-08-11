import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/notification_remote_data_source.dart';
import '../models/notification_response_model.dart';

class NotificationRepository {
  const NotificationRepository(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  Future<List<NotificationResponseModel>> getNotifications() async {
    final page = await getNotificationPage();
    return page.items;
  }

  Future<NotificationPage> getNotificationPage({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(
        page: page,
        limit: limit,
      );
      return _mapNotificationPageResponse(response, page: page, limit: limit);
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

  NotificationPage _mapNotificationPageResponse(
    Map<String, dynamic> response, {
    required int page,
    required int limit,
  }) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;
    final rawMeta = rawData is Map ? rawData['meta'] : null;

    if (isSuccess && rawItems is List) {
      final items = rawItems
          .whereType<Map>()
          .map(
            (item) => NotificationResponseModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
      final currentPage = _readIntFromMap(rawMeta, const ['page']) ?? page;
      final pageLimit = _readIntFromMap(rawMeta, const ['limit']) ?? limit;
      final totalPages = _readIntFromMap(rawMeta, const [
        'total_pages',
        'totalPages',
      ]);
      final hasMore = _readBoolFromMap(rawMeta, const ['hasMore', 'has_more']);

      return NotificationPage(
        items: items,
        page: currentPage,
        limit: pageLimit,
        totalPages: totalPages,
        hasMoreOverride: hasMore,
      );
    }

    if (isSuccess && rawItems == null) {
      return NotificationPage(
        items: const [],
        page: page,
        limit: limit,
        totalPages: page,
      );
    }

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

  int? _readIntFromMap(Object? source, List<String> keys) {
    if (source is! Map) return null;

    for (final key in keys) {
      final value = source[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    return null;
  }

  bool? _readBoolFromMap(Object? source, List<String> keys) {
    if (source is! Map) return null;

    for (final key in keys) {
      final value = source[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'ya') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'tidak') {
        return false;
      }
    }

    return null;
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

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.page,
    required this.limit,
    this.totalPages,
    this.hasMoreOverride,
  });

  final List<NotificationResponseModel> items;
  final int page;
  final int limit;
  final int? totalPages;
  final bool? hasMoreOverride;

  bool get hasMore {
    final override = hasMoreOverride;
    if (override != null) return override;

    final total = totalPages;
    if (total != null) return page < total;

    return items.length >= limit;
  }
}
