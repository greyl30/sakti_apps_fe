import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../presentation/models/attendance_history_model.dart';
import '../datasources/attendance_history_remote_data_source.dart';

// Repository riwayat presensi agar source data mudah diganti/diuji.
class AttendanceHistoryRepository {
  const AttendanceHistoryRepository(this._remoteDataSource);

  final AttendanceHistoryRemoteDataSource _remoteDataSource;

  Future<List<AttendanceHistoryModel>> getAttendanceHistories() async {
    final page = await getAttendanceHistoryPage(limit: 30);
    return page.items;
  }

  Future<AttendanceHistoryPage> getAttendanceHistoryPage({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getAttendanceHistories(
        page: page,
        limit: limit,
      );
      final rawData = response['data'];
      final rawHistories = rawData is Map ? rawData['items'] : null;
      final rawMeta = rawData is Map ? rawData['meta'] : null;
      debugPrint(
        '[AttendanceHistory] raw data type: ${rawData.runtimeType}, '
        'items type: ${rawHistories.runtimeType}',
      );
      debugPrint(
        '[AttendanceHistory] raw item count: '
        '${rawHistories is List ? rawHistories.length : 0}',
      );

      final histories =
          (rawHistories is List ? rawHistories : const [])
              .whereType<Map>()
              .map((history) => AttendanceHistoryModel.fromJson(history))
              .toList()
            ..sort((first, second) => second.date.compareTo(first.date));
      debugPrint('[AttendanceHistory] parsed item count: ${histories.length}');
      final currentPage = _readIntFromMap(rawMeta, const ['page']) ?? page;
      final pageLimit = _readIntFromMap(rawMeta, const ['limit']) ?? limit;
      final totalPages = _readIntFromMap(rawMeta, const [
        'total_pages',
        'totalPages',
      ]);

      return AttendanceHistoryPage(
        items: histories,
        page: currentPage,
        limit: pageLimit,
        totalPages: totalPages,
      );
    } on DioException catch (error) {
      throw AttendanceHistoryException(_mapDioError(error));
    } on SocketException {
      throw const AttendanceHistoryException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (_) {
      throw const AttendanceHistoryException(
        'Gagal mengambil riwayat presensi.',
      );
    }
  }

  String _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Request riwayat presensi melebihi batas waktu.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return 'Tidak dapat terhubung ke server.';
    }

    return 'Gagal mengambil riwayat presensi.';
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
}

class AttendanceHistoryException implements Exception {
  const AttendanceHistoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AttendanceHistoryPage {
  const AttendanceHistoryPage({
    required this.items,
    required this.page,
    required this.limit,
    this.totalPages,
  });

  final List<AttendanceHistoryModel> items;
  final int page;
  final int limit;
  final int? totalPages;

  bool get hasMore {
    final total = totalPages;
    if (total != null) return page < total;

    return items.length >= limit;
  }
}
