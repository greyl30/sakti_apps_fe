import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Remote data source untuk mengambil riwayat presensi user login.
class AttendanceHistoryRemoteDataSource {
  const AttendanceHistoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getAttendanceHistories({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint(
      '[AttendanceHistory] GET /api/attendance/history?page=$page&limit=$limit',
    );
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/attendance/history',
      queryParameters: {'page': page, 'limit': limit},
    );

    debugPrint('[AttendanceHistory] HTTP status: ${response.statusCode}');
    final responseBody = response.data ?? <String, dynamic>{};
    final rawData = responseBody['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;
    debugPrint(
      '[AttendanceHistory] datasource data.items count: '
      '${rawItems is List ? rawItems.length : 0}',
    );
    return responseBody;
  }
}
