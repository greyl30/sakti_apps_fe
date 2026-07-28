import 'package:dio/dio.dart';

import '../models/leave_request_model.dart';

// Remote data source untuk kebutuhan pengajuan cuti karyawan.
class LeaveRemoteDataSource {
  const LeaveRemoteDataSource(this._dio);

  final Dio _dio;

  // Mengambil saldo cuti user login dari backend.
  Future<Map<String, dynamic>> getLeaveBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/leave/balance');

    return response.data ?? <String, dynamic>{};
  }

  // Mengambil status dan riwayat pengajuan cuti user login dari backend.
  Future<Map<String, dynamic>> getLeaveStatuses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/leave/status',
      queryParameters: const {'limit': 10, 'page': 1},
    );

    return response.data ?? <String, dynamic>{};
  }

  // Mengirim pengajuan cuti karyawan ke backend.
  Future<Map<String, dynamic>> submitLeaveRequest(
    LeaveRequestModel request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/leave/request',
      data: request.toJson(),
    );

    return response.data ?? <String, dynamic>{};
  }

  // Membatalkan pengajuan cuti yang sudah final/disetujui.
  Future<Map<String, dynamic>> cancelLeave({
    required String leaveId,
    required String reason,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/leave/$leaveId/cancel',
      data: {'alasan': reason},
    );

    return response.data ?? <String, dynamic>{};
  }
}
