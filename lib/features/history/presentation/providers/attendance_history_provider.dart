import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
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
      final histories = await repository.getAttendanceHistories();
      debugPrint(
        '[AttendanceHistory] provider item count: ${histories.length}',
      );
      return histories;
    });
