import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datasources/hrd_leave_finalization_remote_data_source.dart';
import '../models/hrd_leave_finalization_model.dart';

// Repository untuk daftar cuti yang menunggu finalisasi HRD.
class HrdLeaveFinalizationRepository {
  const HrdLeaveFinalizationRepository(this._remoteDataSource);

  final HrdLeaveFinalizationRemoteDataSource _remoteDataSource;

  Future<List<HrdLeaveFinalizationModel>> getFinalizations() async {
    try {
      final response = await _remoteDataSource.getFinalizations();
      return _mapFinalizationResponse(response);
    } on HrdLeaveFinalizationException {
      rethrow;
    } on DioException catch (error) {
      throw HrdLeaveFinalizationException(
        _mapDioError(
          error,
          timeoutMessage: 'Request finalisasi cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal mengambil finalisasi cuti.',
        ),
      );
    } on SocketException {
      throw const HrdLeaveFinalizationException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (error, stackTrace) {
      debugPrint('HRD leave finalization unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const HrdLeaveFinalizationException(
        'Gagal mengambil finalisasi cuti.',
      );
    }
  }

  Future<void> finalizeLeave(String leaveId) async {
    try {
      final response = await _remoteDataSource.finalizeLeave(leaveId);
      _validateActionResponse(response);
    } on HrdLeaveFinalizationException {
      rethrow;
    } on DioException catch (error) {
      throw HrdLeaveFinalizationException(
        _mapDioError(
          error,
          timeoutMessage: 'Request finalisasi cuti melebihi batas waktu.',
          fallbackMessage: 'Gagal melakukan finalisasi cuti.',
        ),
      );
    } on SocketException {
      throw const HrdLeaveFinalizationException(
        'Tidak dapat terhubung ke server.',
      );
    } catch (error, stackTrace) {
      debugPrint('HRD leave finalize unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const HrdLeaveFinalizationException(
        'Gagal melakukan finalisasi cuti.',
      );
    }
  }

  List<HrdLeaveFinalizationModel> _mapFinalizationResponse(
    Map<String, dynamic> response,
  ) {
    final isSuccess = response['success'] == true;
    final rawData = response['data'];
    final rawItems = rawData is Map ? rawData['items'] : null;

    if (isSuccess && rawItems is List) {
      return rawItems
          .whereType<Map>()
          .map(
            (item) => HrdLeaveFinalizationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (isSuccess && rawItems == null) return const [];

    throw HrdLeaveFinalizationException(_readApiMessage(response));
  }

  void _validateActionResponse(Map<String, dynamic> response) {
    final hasSuccessField = response.containsKey('success');
    if (!hasSuccessField || response['success'] == true) return;

    throw HrdLeaveFinalizationException(_readApiMessage(response));
  }

  String _readApiMessage(Map<String, dynamic> response) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    return 'Finalisasi cuti gagal diproses.';
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

class HrdLeaveFinalizationException implements Exception {
  const HrdLeaveFinalizationException(this.message);

  final String message;

  @override
  String toString() => message;
}
