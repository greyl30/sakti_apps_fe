import 'package:dio/dio.dart';

// Remote data source untuk daftar cuti yang perlu difinalisasi HRD.
class HrdLeaveFinalizationRemoteDataSource {
  const HrdLeaveFinalizationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getFinalizations() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/leave/finalization/list',
      queryParameters: const {'limit': 10, 'page': 1},
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> finalizeLeave(String leaveId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/leave/$leaveId/finalize',
    );

    return response.data ?? <String, dynamic>{};
  }
}
