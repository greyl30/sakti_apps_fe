import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../presentation/models/leave_form_data.dart';
import '../datasources/leave_remote_data_source.dart';
import '../models/leave_request_model.dart';

// Repository untuk kebutuhan data pengajuan cuti.
class LeaveRepository {
  const LeaveRepository(this._remoteDataSource);

  final LeaveRemoteDataSource _remoteDataSource;

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

class LeaveRequestException implements Exception {
  const LeaveRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
