import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/leave_letter_download.dart';
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

  // Mengambil hari libur aktif dari backend untuk estimasi durasi hari kerja.
  Future<Map<String, dynamic>> getActiveHolidays() async {
    const path = '/api/libur';

    debugPrint('[LeaveHoliday] GET $path');

    try {
      final response = await _dio.get<Map<String, dynamic>>(path);

      debugPrint('[LeaveHoliday] URL: ${response.realUri}');
      debugPrint('[LeaveHoliday] status: ${response.statusCode}');
      debugPrint('[LeaveHoliday] body: ${response.data}');

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      debugPrint('[LeaveHoliday] URL: ${error.requestOptions.uri}');
      debugPrint(
        '[LeaveHoliday] Authorization header exists: '
        '${error.requestOptions.headers.containsKey('Authorization')}',
      );
      debugPrint('[LeaveHoliday] error type: ${error.type}');
      debugPrint('[LeaveHoliday] status: ${error.response?.statusCode}');
      debugPrint('[LeaveHoliday] response body: ${error.response?.data}');
      debugPrint('[LeaveHoliday] raw error: ${error.error}');
      rethrow;
    }
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

  // Mengunduh surat cuti/dispensasi dalam format PDF.
  Future<LeaveLetterDownload> downloadLeaveLetter(String leaveId) async {
    final response = await _dio.get<List<int>>(
      '/api/leave/$leaveId/download',
      options: Options(
        responseType: ResponseType.bytes,
        headers: const {'Accept': 'application/pdf'},
      ),
    );

    return LeaveLetterDownload(
      fileName: _readFileName(response.headers),
      bytes: response.data ?? const <int>[],
    );
  }

  String _readFileName(Headers headers) {
    final contentDisposition = headers.value('content-disposition') ?? '';
    final encodedMatch = RegExp(
      r'''filename\*=UTF-8''([^;]+)''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    final encodedFileName = encodedMatch?.group(1);
    if (encodedFileName != null && encodedFileName.trim().isNotEmpty) {
      return Uri.decodeComponent(encodedFileName.trim());
    }

    final fileNameMatch = RegExp(
      r'''filename="?([^";]+)"?''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    final fileName = fileNameMatch?.group(1)?.trim();
    if (fileName != null && fileName.isNotEmpty) return fileName;

    return 'surat-cuti.pdf';
  }
}
