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
    try {
      final response = await _remoteDataSource.getAttendanceHistories();
      final rawData = response['data'];
      final rawHistories = rawData is Map ? rawData['items'] : null;
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
      return histories;
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
}

class AttendanceHistoryException implements Exception {
  const AttendanceHistoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
