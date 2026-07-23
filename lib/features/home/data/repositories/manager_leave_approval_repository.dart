import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/manager_leave_approval_remote_data_source.dart';
import '../models/manager_leave_approval_model.dart';

// Repository untuk daftar pengajuan cuti yang menunggu persetujuan Atasan.
class ManagerLeaveApprovalRepository {
  const ManagerLeaveApprovalRepository(this._remoteDataSource);

  final ManagerLeaveApprovalRemoteDataSource _remoteDataSource;

  Future<List<ManagerLeaveApprovalModel>> getPendingApprovals() async {
    try {
      final response = await _remoteDataSource.getPendingApprovals();
      return _mapApprovalResponse(response);
    } on ManagerLeaveApprovalException {
      rethrow;
    } on DioException catch (error) {
      throw ManagerLeaveApprovalException(
        _mapDioError(
          error,
          timeoutMessage: 'Request pengajuan cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil pengajuan cuti.',
        ),
      );
    } on SocketException {
      throw const ManagerLeaveApprovalException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (error, stackTrace) {
      debugPrint('Manager leave approval unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const ManagerLeaveApprovalException(
        'Gagal mengambil pengajuan cuti.',
      );
    }
  }

  Future<void> approveLeave(String leaveId) async {
    try {
      final response = await _remoteDataSource.approveLeave(leaveId);
      _validateActionResponse(response);
    } on ManagerLeaveApprovalException {
      rethrow;
    } on DioException catch (error) {
      throw ManagerLeaveApprovalException(
        _mapDioError(
          error,
          timeoutMessage: 'Request persetujuan cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal menyetujui pengajuan cuti.',
        ),
      );
    } on SocketException {
      throw const ManagerLeaveApprovalException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (error, stackTrace) {
      debugPrint('Manager leave approve unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const ManagerLeaveApprovalException(
        'Gagal menyetujui pengajuan cuti.',
      );
    }
  }

  Future<void> rejectLeave({
    required String leaveId,
    required String reason,
  }) async {
    try {
      final response = await _remoteDataSource.rejectLeave(
        leaveId: leaveId,
        reason: reason,
      );
      _validateActionResponse(response);
    } on ManagerLeaveApprovalException {
      rethrow;
    } on DioException catch (error) {
      throw ManagerLeaveApprovalException(
        _mapDioError(
          error,
          timeoutMessage: 'Request penolakan cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal menolak pengajuan cuti.',
        ),
      );
    } on SocketException {
      throw const ManagerLeaveApprovalException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (error, stackTrace) {
      debugPrint('Manager leave reject unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const ManagerLeaveApprovalException(
        'Gagal menolak pengajuan cuti.',
      );
    }
  }

  List<ManagerLeaveApprovalModel> _mapApprovalResponse(
    Map<String, dynamic> response,
  ) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;

    if (isSuccess && rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) => ManagerLeaveApprovalModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (isSuccess && rawItems == null) return const [];

    throw ManagerLeaveApprovalException(_readApiMessage(response));
  }

  void _validateActionResponse(Map<String, dynamic> response) {
    final hasSuccessField = response.containsKey('success');
    if (!hasSuccessField || response['success'] == true) return;

    throw ManagerLeaveApprovalException(_readApiMessage(response));
  }

  String _readApiMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return 'Pengajuan cuti gagal dimuat.';
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

class ManagerLeaveApprovalException implements Exception {
  const ManagerLeaveApprovalException(this.message);

  final String message;

  @override
  String toString() => message;
}
