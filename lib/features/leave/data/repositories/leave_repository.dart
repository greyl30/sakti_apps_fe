import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../presentation/models/leave_form_data.dart';
import '../datasources/leave_remote_data_source.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_holiday_model.dart';
import '../models/leave_letter_download.dart';
import '../models/leave_request_model.dart';

// Repository untuk kebutuhan data pengajuan cuti.
class LeaveRepository {
  const LeaveRepository(this._remoteDataSource);

  final LeaveRemoteDataSource _remoteDataSource;

  // Mengambil saldo cuti user login untuk ringkasan halaman Cuti.
  Future<LeaveBalanceModel> getLeaveBalance() async {
    try {
      final response = await _remoteDataSource.getLeaveBalance();
      return _mapBalanceResponse(response);
    } on LeaveBalanceException {
      rethrow;
    } on DioException catch (error) {
      throw LeaveBalanceException(
        _mapDioError(
          error,
          timeoutMessage: 'Request saldo cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil saldo cuti.',
        ),
      );
    } on SocketException {
      throw const LeaveBalanceException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Leave balance unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const LeaveBalanceException('Gagal mengambil saldo cuti.');
    }
  }

  // Mengambil daftar pengajuan cuti user login dari backend.
  Future<List<LeaveRequestResponse>> getLeaveStatuses() async {
    final page = await getLeaveStatusPage();
    return page.items;
  }

  Future<LeaveStatusPage> getLeaveStatusPage({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _remoteDataSource.getLeaveStatuses(
        page: page,
        limit: limit,
      );
      return _mapStatusPageResponse(response, page: page, limit: limit);
    } on LeaveStatusException {
      rethrow;
    } on DioException catch (error) {
      throw LeaveStatusException(
        _mapDioError(
          error,
          timeoutMessage: 'Request data pengajuan cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil data pengajuan cuti.',
        ),
      );
    } on SocketException {
      throw const LeaveStatusException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Leave status unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const LeaveStatusException('Gagal mengambil data pengajuan cuti.');
    }
  }

  // Mengambil hari libur aktif untuk estimasi durasi pengajuan di FE.
  Future<List<LeaveHolidayModel>> getActiveHolidays() async {
    try {
      final response = await _remoteDataSource.getActiveHolidays();
      return _mapHolidayResponse(response);
    } on LeaveHolidayException {
      rethrow;
    } on DioException catch (error) {
      throw LeaveHolidayException(
        _mapDioError(
          error,
          timeoutMessage: 'Request data hari libur melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil data hari libur.',
        ),
      );
    } on SocketException {
      throw const LeaveHolidayException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Leave holiday unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const LeaveHolidayException('Gagal mengambil data hari libur.');
    }
  }

  // Submit pengajuan dari form UI dengan mapper request API.
  Future<LeaveRequestResponse> submitLeaveForm(LeaveFormData formData) {
    return submitLeaveRequest(LeaveRequestModel.fromFormData(formData));
  }

  // Submit pengajuan cuti dan mengembalikan model response API.
  Future<LeaveRequestResponse> submitLeaveRequest(
    LeaveRequestModel request,
  ) async {
    try {
      final response = await _remoteDataSource.submitLeaveRequest(request);
      return _mapSubmitResponse(response);
    } on LeaveRequestException {
      rethrow;
    } on DioException catch (error) {
      throw LeaveRequestException(
        _mapDioError(
          error,
          timeoutMessage: 'Request pengajuan cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal mengirim pengajuan cuti.',
        ),
      );
    } on SocketException {
      throw const LeaveRequestException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Leave request unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const LeaveRequestException('Gagal mengirim pengajuan cuti.');
    }
  }

  // Batalkan pengajuan cuti final/disetujui di backend.
  Future<void> cancelLeave({
    required String leaveId,
    required String reason,
  }) async {
    try {
      final response = await _remoteDataSource.cancelLeave(
        leaveId: leaveId,
        reason: reason,
      );
      if (response['success'] != true) {
        throw LeaveCancelException(_readApiMessage(response));
      }
    } on LeaveCancelException {
      rethrow;
    } on DioException catch (error) {
      throw LeaveCancelException(
        _mapDioError(
          error,
          timeoutMessage: 'Request pembatalan cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal membatalkan cuti.',
        ),
      );
    } on SocketException {
      throw const LeaveCancelException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Leave cancel unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const LeaveCancelException('Gagal membatalkan cuti.');
    }
  }

  Future<LeaveLetterDownload> downloadLeaveLetter(String leaveId) async {
    try {
      final download = await _remoteDataSource.downloadLeaveLetter(leaveId);
      if (download.bytes.isEmpty) {
        throw const LeaveDownloadException('File surat kosong.');
      }
      return download;
    } on LeaveDownloadException {
      rethrow;
    } on DioException catch (error) {
      throw LeaveDownloadException(
        _mapDioError(
          error,
          timeoutMessage: 'Request unduh surat melebihi batas waktu.',
          fallbackMessage: 'Gagal mengunduh surat.',
        ),
      );
    } on SocketException {
      throw const LeaveDownloadException('Tidak dapat terhubung ke server.');
    } catch (error, stackTrace) {
      debugPrint('Leave letter download unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const LeaveDownloadException('Gagal mengunduh surat.');
    }
  }

  LeaveBalanceModel _mapBalanceResponse(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];

    if (isSuccess && rawData is Map<String, dynamic>) {
      return LeaveBalanceModel.fromJson(rawData);
    }

    if (isSuccess && rawData is Map) {
      return LeaveBalanceModel.fromJson(Map<String, dynamic>.from(rawData));
    }

    throw LeaveBalanceException(_readApiMessage(response));
  }

  LeaveStatusPage _mapStatusPageResponse(
    Map<String, dynamic> response, {
    required int page,
    required int limit,
  }) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;
    final rawMeta = rawData is Map ? rawData['meta'] : null;

    if (isSuccess && rawItems is List) {
      final items = rawItems
          .whereType<Map>()
          .map(
            (item) =>
                LeaveRequestResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      final currentPage = _readIntFromMap(rawMeta, const ['page']) ?? page;
      final pageLimit = _readIntFromMap(rawMeta, const ['limit']) ?? limit;
      final totalPages = _readIntFromMap(rawMeta, const [
        'total_pages',
        'totalPages',
      ]);

      return LeaveStatusPage(
        items: items,
        page: currentPage,
        limit: pageLimit,
        totalPages: totalPages,
      );
    }

    if (isSuccess && rawItems == null) {
      return LeaveStatusPage(
        items: const [],
        page: page,
        limit: limit,
        totalPages: page,
      );
    }

    throw LeaveStatusException(_readApiMessage(response));
  }

  List<LeaveHolidayModel> _mapHolidayResponse(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : rawData;

    if (isSuccess && rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) =>
                LeaveHolidayModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((holiday) => holiday.isActive)
          .toList();
    }

    if (isSuccess && rawItems == null) return const [];

    throw LeaveHolidayException(_readApiMessage(response));
  }

  LeaveRequestResponse _mapSubmitResponse(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];

    if (isSuccess && rawData is Map) {
      return LeaveRequestResponse.fromApiResponse(response);
    }

    throw LeaveRequestException(_readApiMessage(response));
  }

  String _readApiMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return 'Pengajuan cuti gagal diproses.';
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

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang tidak tersedia.';
    }

    return fallbackMessage;
  }
}

class LeaveBalanceException implements Exception {
  const LeaveBalanceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeaveStatusException implements Exception {
  const LeaveStatusException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeaveHolidayException implements Exception {
  const LeaveHolidayException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeaveRequestException implements Exception {
  const LeaveRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeaveCancelException implements Exception {
  const LeaveCancelException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeaveDownloadException implements Exception {
  const LeaveDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeaveStatusPage {
  const LeaveStatusPage({
    required this.items,
    required this.page,
    required this.limit,
    this.totalPages,
  });

  final List<LeaveRequestResponse> items;
  final int page;
  final int limit;
  final int? totalPages;

  bool get hasMore {
    final total = totalPages;
    if (total != null) return page < total;

    return items.length >= limit;
  }
}
