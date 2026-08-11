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

final paginatedAttendanceHistoriesProvider =
    StateNotifierProvider<
      PaginatedAttendanceHistoriesNotifier,
      PaginatedAttendanceHistoriesState
    >((ref) {
      final repository = ref.watch(attendanceHistoryRepositoryProvider);
      final userId = ref.watch(authProvider.select((state) => state.user?.id));
      return PaginatedAttendanceHistoriesNotifier(repository, userId)..load();
    });

class PaginatedAttendanceHistoriesState {
  const PaginatedAttendanceHistoriesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<AttendanceHistoryModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  PaginatedAttendanceHistoriesState copyWith({
    List<AttendanceHistoryModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaginatedAttendanceHistoriesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PaginatedAttendanceHistoriesNotifier
    extends StateNotifier<PaginatedAttendanceHistoriesState> {
  PaginatedAttendanceHistoriesNotifier(this._repository, this._userId)
    : super(const PaginatedAttendanceHistoriesState(isLoading: true));

  static const _limit = 10;

  final AttendanceHistoryRepository _repository;
  final String? _userId;
  int _page = 0;

  Future<void> load() async {
    _page = 0;
    state = const PaginatedAttendanceHistoriesState(isLoading: true);
    await _loadPage(1, append: false);
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _loadPage(_page + 1, append: true);
  }

  Future<void> _loadPage(int page, {required bool append}) async {
    try {
      final response = await _repository.getAttendanceHistoryPage(
        page: page,
        limit: _limit,
      );
      final filteredItems = _filterCurrentUserHistories(
        response.items,
        _userId,
      );
      _page = response.page;
      state = PaginatedAttendanceHistoriesState(
        items: append
            ? _uniqueHistories([...state.items, ...filteredItems])
            : _uniqueHistories(filteredItems),
        hasMore: response.hasMore,
      );
    } on AttendanceHistoryException catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Gagal mengambil riwayat presensi.',
      );
    }
  }

  List<AttendanceHistoryModel> _uniqueHistories(
    List<AttendanceHistoryModel> histories,
  ) {
    final seenKeys = <String>{};
    final uniqueHistories = <AttendanceHistoryModel>[];

    for (final history in histories) {
      final key = history.id.trim().isNotEmpty
          ? history.id
          : '${history.employeeId}-${history.date.toIso8601String()}-'
                '${history.clockInTime}-${history.clockOutTime}';
      if (!seenKeys.add(key)) continue;

      uniqueHistories.add(history);
    }

    return uniqueHistories;
  }
}

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
