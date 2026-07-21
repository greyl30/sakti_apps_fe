import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Remote data source untuk mengambil riwayat presensi user login.
class AttendanceHistoryRemoteDataSource {
  const AttendanceHistoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getAttendanceHistories() async {
    debugPrint(
      '[AttendanceHistory] GET /api/attendance/history?page=1&limit=30',
    );
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/attendance/history',
      queryParameters: const {'page': 1, 'limit': 30},
    );

    debugPrint('[AttendanceHistory] HTTP status: ${response.statusCode}');
    debugPrint('[AttendanceHistory] Raw response: ${response.data}');
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
