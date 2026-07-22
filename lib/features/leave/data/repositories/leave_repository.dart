import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../presentation/models/leave_form_data.dart';
import '../datasources/leave_remote_data_source.dart';
import '../models/leave_balance_model.dart';
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
    try {
      final response = await _remoteDataSource.getLeaveStatuses();
      return _mapStatusResponse(response);
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

  List<LeaveRequestResponse> _mapStatusResponse(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;

    if (isSuccess && rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) =>
                LeaveRequestResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (isSuccess && rawItems == null) return const [];

    throw LeaveStatusException(_readApiMessage(response));
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

class LeaveRequestException implements Exception {
  const LeaveRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
