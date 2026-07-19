import 'dart:io';

import 'package:dio/dio.dart';

import '../datasources/attendance_remote_data_source.dart';
import '../models/attendance_submit_response.dart';
import '../models/attendance_work_config.dart';

// Repository untuk kebutuhan data presensi.
class AttendanceRepository {
  const AttendanceRepository(this._remoteDataSource);

  final AttendanceRemoteDataSource _remoteDataSource;

  // Upload foto presensi dan mengembalikan URL file dari backend.
  Future<String> uploadImage(File imageFile) async {
    try {
      final data = await _remoteDataSource.uploadImage(imageFile);
      final url = data['url'];

      if (url is String && url.trim().isNotEmpty) {
        return url;
      }

      throw const AttendanceUploadException(
        'URL foto tidak ditemukan dari server.',
      );
    } on AttendanceUploadException {
      rethrow;
    } on DioException catch (error) {
      throw AttendanceUploadException(
        _mapDioError(
          error,
          timeoutMessage: 'Upload foto melebihi batas waktu.',
          fallbackMessage: 'Gagal mengunggah foto presensi.',
        ),
      );
    } on SocketException {
      throw const AttendanceUploadException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const AttendanceUploadException('Gagal mengunggah foto presensi.');
    }
  }

  // Mengambil konfigurasi jam kerja untuk menentukan flow lembur.
  Future<AttendanceWorkConfig> getWorkConfig() async {
    try {
      final data = await _remoteDataSource.getWorkConfig();
      final isSuccess = data['success'] == true;
      final rawConfig = data['data'];

      if (isSuccess && rawConfig is Map<String, dynamic>) {
        return AttendanceWorkConfig.fromJson(rawConfig);
      }

      throw const AttendanceWorkConfigException(
        'Konfigurasi jam kerja tidak tersedia.',
      );
    } on AttendanceWorkConfigException {
      rethrow;
    } on DioException catch (error) {
      throw AttendanceWorkConfigException(
        _mapDioError(
          error,
          timeoutMessage: 'Request konfigurasi jam kerja melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil konfigurasi jam kerja.',
        ),
      );
    } on SocketException {
      throw const AttendanceWorkConfigException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (_) {
      throw const AttendanceWorkConfigException(
        'Gagal mengambil konfigurasi jam kerja.',
      );
    }
  }

  // Submit presensi masuk setelah foto berhasil di-upload.
  Future<AttendanceSubmitResponse> checkIn({
    required String selfieUrl,
    required double latitude,
    required double longitude,
    required String lateReason,
  }) async {
    try {
      final data = await _remoteDataSource.checkIn(
        selfieUrl: selfieUrl,
        latitude: latitude,
        longitude: longitude,
        lateReason: lateReason,
      );

      return _mapSubmitResponse(data);
    } on AttendanceSubmitException {
      rethrow;
    } on DioException catch (error) {
      throw AttendanceSubmitException(
        _mapDioError(
          error,
          timeoutMessage: 'Request presensi melebihi batas waktu.',
          fallbackMessage: 'Gagal mengirim presensi masuk.',
        ),
      );
    } on SocketException {
      throw const AttendanceSubmitException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const AttendanceSubmitException('Gagal mengirim presensi masuk.');
    }
  }

  // Submit presensi keluar setelah foto berhasil di-upload.
  Future<AttendanceSubmitResponse> checkOut({
    required String selfieUrl,
    required double latitude,
    required double longitude,
    required bool overtime,
  }) async {
    try {
      final data = await _remoteDataSource.checkOut(
        selfieUrl: selfieUrl,
        latitude: latitude,
        longitude: longitude,
        overtime: overtime,
      );

      return _mapSubmitResponse(data);
    } on AttendanceSubmitException {
      rethrow;
    } on DioException catch (error) {
      throw AttendanceSubmitException(
        _mapDioError(
          error,
          timeoutMessage: 'Request presensi melebihi batas waktu.',
          fallbackMessage: 'Gagal mengirim presensi keluar.',
        ),
      );
    } on SocketException {
      throw const AttendanceSubmitException('Tidak dapat terhubung ke server.');
    } catch (_) {
      throw const AttendanceSubmitException('Gagal mengirim presensi keluar.');
    }
  }

  AttendanceSubmitResponse _mapSubmitResponse(Map<String, dynamic> data) {
    final response = AttendanceSubmitResponse.fromJson(data);
    if (response.success) return response;

    throw AttendanceSubmitException(
      response.message.trim().isEmpty
          ? 'Presensi gagal diproses.'
          : response.message,
    );
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

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang tidak tersedia.';
    }

    return fallbackMessage;
  }
}

class AttendanceUploadException implements Exception {
  const AttendanceUploadException(this.message);

  final String message;
}

class AttendanceSubmitException implements Exception {
  const AttendanceSubmitException(this.message);

  final String message;
}

class AttendanceWorkConfigException implements Exception {
  const AttendanceWorkConfigException(this.message);

  final String message;
}
