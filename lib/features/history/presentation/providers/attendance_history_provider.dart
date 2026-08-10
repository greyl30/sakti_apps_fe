import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/attendance_history_remote_data_source.dart';
import '../../data/repositories/attendance_history_repository.dart';
import '../models/attendance_history_model.dart';

final attendanceHistoryRemoteDataSourceProvider =
    Provider<AttendanceHistoryRemoteDataSource>((ref) {
      return AttendanceHistoryRemoteDataSource(ApiClient.dio);
    });

final attendanceHistoryRepositoryProvider =
    Provider<AttendanceHistoryRepository>((ref) {
      final remoteDataSource = ref.watch(
        attendanceHistoryRemoteDataSourceProvider,
      );
      return AttendanceHistoryRepository(remoteDataSource);
    });

// TODO(Backend):
// Backend mengirim riwayat presensi user login, FE hanya menampilkan data.
final attendanceHistoriesProvider =
    FutureProvider<List<AttendanceHistoryModel>>((ref) async {
      final repository = ref.watch(attendanceHistoryRepositoryProvider);
      final userId = ref.watch(authProvider.select((state) => state.user?.id));
      final histories = await repository.getAttendanceHistories();
      final filteredHistories = _filterCurrentUserHistories(histories, userId);
      debugPrint(
        '[AttendanceHistory] provider item count: '
        '${filteredHistories.length}',
      );
      return filteredHistories;
    });

List<AttendanceHistoryModel> _filterCurrentUserHistories(
  List<AttendanceHistoryModel> histories,
  String? userId,
) {
  final normalizedUserId = userId?.trim();
  if (normalizedUserId == null || normalizedUserId.isEmpty) return histories;

  final hasEmployeeIds = histories.any(
    (history) => history.employeeId.trim().isNotEmpty,
  );
  if (!hasEmployeeIds) return histories;

  return histories
      .where((history) => history.employeeId.trim() == normalizedUserId)
      .toList();
}
