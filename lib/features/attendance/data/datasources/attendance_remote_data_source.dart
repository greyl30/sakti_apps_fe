import 'dart:io';

import 'package:dio/dio.dart';

// Remote data source untuk kebutuhan presensi.
class AttendanceRemoteDataSource {
  const AttendanceRemoteDataSource(this._dio);

  final Dio _dio;

  // Upload foto presensi yang sudah di-resize ke backend.
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/upload/image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data ?? <String, dynamic>{};
  }

  // Mengambil konfigurasi jam kerja dari backend.
  Future<Map<String, dynamic>> getWorkConfig() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/attendance/work-config',
    );

    return response.data ?? <String, dynamic>{};
  }

  // Submit presensi masuk menggunakan URL selfie hasil upload.
  Future<Map<String, dynamic>> checkIn({
    required String selfieUrl,
    required double latitude,
    required double longitude,
    required String lateReason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/attendance/check-in',
      data: {
        'selfie_url': selfieUrl,
        'latitude': latitude,
        'longitude': longitude,
        'alasan_terlambat': lateReason,
      },
    );

    return response.data ?? <String, dynamic>{};
  }

  // Submit presensi keluar menggunakan URL selfie hasil upload.
  Future<Map<String, dynamic>> checkOut({
    required String selfieUrl,
    required double latitude,
    required double longitude,
    required bool overtime,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/attendance/check-out',
      data: {
        'selfie_url': selfieUrl,
        'latitude': latitude,
        'longitude': longitude,
        'lembur': overtime,
      },
    );

    return response.data ?? <String, dynamic>{};
  }
}
