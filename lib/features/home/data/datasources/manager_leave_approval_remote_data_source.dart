import 'package:dio/dio.dart';

// Remote data source untuk daftar pengajuan cuti yang perlu diproses Atasan.
class ManagerLeaveApprovalRemoteDataSource {
  const ManagerLeaveApprovalRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getPendingApprovals() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/leave/approval/list',
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> approveLeave(String leaveId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/leave/$leaveId/approve',
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> rejectLeave({
    required String leaveId,
    required String reason,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/leave/$leaveId/reject',
      data: {'alasan': reason},
    );

    return response.data ?? <String, dynamic>{};
  }
}
