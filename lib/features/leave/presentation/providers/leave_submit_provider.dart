import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/leave_remote_data_source.dart';
import '../../data/models/leave_balance_model.dart';
import '../../data/models/leave_request_model.dart';
import '../../data/repositories/leave_repository.dart';
import '../models/leave_form_data.dart';
import '../utils/leave_workday_calculator.dart';

enum LeaveSubmitStatus { initial, loading, success, error }

class LeaveSubmitState {
  const LeaveSubmitState({
    this.status = LeaveSubmitStatus.initial,
    this.response,
    this.errorMessage,
  });

  final LeaveSubmitStatus status;
  final LeaveRequestResponse? response;
  final String? errorMessage;

  bool get isLoading => status == LeaveSubmitStatus.loading;

  LeaveSubmitState copyWith({
    LeaveSubmitStatus? status,
    LeaveRequestResponse? response,
    String? errorMessage,
    bool clearResult = false,
  }) {
    return LeaveSubmitState(
      status: status ?? this.status,
      response: clearResult ? null : response ?? this.response,
      errorMessage: clearResult ? null : errorMessage,
    );
  }
}

final leaveRemoteDataSourceProvider = Provider<LeaveRemoteDataSource>((ref) {
  return LeaveRemoteDataSource(ApiClient.dio);
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final remoteDataSource = ref.watch(leaveRemoteDataSourceProvider);
  return LeaveRepository(remoteDataSource);
});

final leaveSubmitProvider =
    StateNotifierProvider<LeaveSubmitNotifier, LeaveSubmitState>((ref) {
      final repository = ref.watch(leaveRepositoryProvider);
      return LeaveSubmitNotifier(repository);
    });

// TODO(Backend):
// Backend mengirim saldo cuti user login, FE hanya menampilkan data.
final leaveBalanceProvider = FutureProvider<LeaveBalanceModel>((ref) async {
  final repository = ref.watch(leaveRepositoryProvider);
  return repository.getLeaveBalance();
});

// TODO(Backend):
// Backend mengirim daftar pengajuan user login, FE membagi data aktif/riwayat.
final leaveStatusesProvider = FutureProvider<List<LeaveRequestResponse>>((
  ref,
) async {
  final repository = ref.watch(leaveRepositoryProvider);
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  final statuses = await repository.getLeaveStatuses();

  if (userId == null || userId.isEmpty) return statuses;

  return statuses.where((request) => request.employeeId == userId).toList();
});

final activeLeaveHolidayDatesProvider = FutureProvider<Set<DateTime>>((
  ref,
) async {
  final repository = ref.watch(leaveRepositoryProvider);
  final holidays = await repository.getActiveHolidays();
  return holidays.map((holiday) => normalizeLeaveDate(holiday.date)).toSet();
});

final activeLeaveRequestsProvider = FutureProvider<List<LeaveRequestResponse>>((
  ref,
) async {
  final statuses = await ref.watch(leaveStatusesProvider.future);
  return statuses.where((request) => request.isActiveStatus).toList();
});

final leaveHistoryRequestsProvider = FutureProvider<List<LeaveRequestResponse>>(
  (ref) async {
    final statuses = await ref.watch(leaveStatusesProvider.future);
    return statuses.where((request) => request.isHistoryStatus).toList();
  },
);

final calendarLeaveRequestsProvider = FutureProvider<List<LeaveRequestResponse>>((
  ref,
) async {
  final repository = ref.watch(leaveRepositoryProvider);
  final userId = ref.watch(authProvider.select((state) => state.user?.id));
  final requests = <LeaveRequestResponse>[];
  var page = 1;
  var hasMore = true;

  while (hasMore) {
    final response = await repository.getLeaveStatusPage(page: page, limit: 20);
    debugPrint(
      '[CalendarLeave] page=${response.page}, count=${response.items.length}, '
      'hasMore=${response.hasMore}, totalPages=${response.totalPages}',
    );
    requests.addAll(response.items);
    hasMore = response.hasMore;
    page = response.page + 1;
  }

  final uniqueRequests = _uniqueLeaveRequests(requests);
  debugPrint(
    '[CalendarLeave] userId=$userId, raw=${requests.length}, '
    'unique=${uniqueRequests.length}',
  );

  if (userId == null || userId.isEmpty) return uniqueRequests;

  final filteredRequests = uniqueRequests
      .where((request) => request.employeeId == userId)
      .toList();
  debugPrint(
    '[CalendarLeave] filteredByUser=${filteredRequests.length}, '
    'removed=${uniqueRequests.length - filteredRequests.length}',
  );
  return filteredRequests;
});

List<LeaveRequestResponse> _uniqueLeaveRequests(
  List<LeaveRequestResponse> requests,
) {
  final seenKeys = <String>{};
  final uniqueRequests = <LeaveRequestResponse>[];

  for (final request in requests) {
    final key = request.id.trim().isNotEmpty
        ? request.id
        : '${request.employeeId}-${request.subType}-'
              '${request.startDate.toIso8601String()}-'
              '${request.endDate.toIso8601String()}-${request.status}';
    if (!seenKeys.add(key)) continue;

    uniqueRequests.add(request);
  }

  return uniqueRequests;
}

final paginatedLeaveHistoryProvider =
    StateNotifierProvider<
      PaginatedLeaveHistoryNotifier,
      PaginatedLeaveHistoryState
    >((ref) {
      final repository = ref.watch(leaveRepositoryProvider);
      final userId = ref.watch(authProvider.select((state) => state.user?.id));
      return PaginatedLeaveHistoryNotifier(repository, userId)..load();
    });

class PaginatedLeaveHistoryState {
  const PaginatedLeaveHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<LeaveRequestResponse> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  PaginatedLeaveHistoryState copyWith({
    List<LeaveRequestResponse>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaginatedLeaveHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PaginatedLeaveHistoryNotifier
    extends StateNotifier<PaginatedLeaveHistoryState> {
  PaginatedLeaveHistoryNotifier(this._repository, this._userId)
    : super(const PaginatedLeaveHistoryState(isLoading: true));

  static const _limit = 10;

  final LeaveRepository _repository;
  final String? _userId;
  int _page = 0;

  Future<void> load() async {
    _page = 0;
    state = const PaginatedLeaveHistoryState(isLoading: true);
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
      final response = await _repository.getLeaveStatusPage(
        page: page,
        limit: _limit,
      );
      final historyItems = _filterHistoryItems(response.items);
      _page = response.page;
      state = PaginatedLeaveHistoryState(
        items: append ? [...state.items, ...historyItems] : historyItems,
        hasMore: response.hasMore,
      );
    } on LeaveStatusException catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Riwayat pengajuan belum dapat dimuat.',
      );
    }
  }

  List<LeaveRequestResponse> _filterHistoryItems(
    List<LeaveRequestResponse> items,
  ) {
    final userId = _userId?.trim();
    return items.where((request) {
      final isCurrentUser =
          userId == null || userId.isEmpty || request.employeeId == userId;
      return isCurrentUser && request.isHistoryStatus;
    }).toList();
  }
}

class LeaveCancelState {
  const LeaveCancelState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;
}

class LeaveLetterDownloadState {
  const LeaveLetterDownloadState({this.processingId, this.errorMessage});

  final String? processingId;
  final String? errorMessage;

  bool get isLoading => processingId != null;

  bool isProcessing(String leaveId) => processingId == leaveId;
}

final leaveCancelProvider =
    StateNotifierProvider<LeaveCancelNotifier, LeaveCancelState>((ref) {
      final repository = ref.watch(leaveRepositoryProvider);
      return LeaveCancelNotifier(ref, repository);
    });

final leaveLetterDownloadProvider =
    StateNotifierProvider<
      LeaveLetterDownloadNotifier,
      LeaveLetterDownloadState
    >((ref) {
      final repository = ref.watch(leaveRepositoryProvider);
      return LeaveLetterDownloadNotifier(repository);
    });

class LeaveSubmitNotifier extends StateNotifier<LeaveSubmitState> {
  LeaveSubmitNotifier(this._repository) : super(const LeaveSubmitState());

  final LeaveRepository _repository;

  // TODO(Backend):
  // Kirim pengajuan cuti karyawan ke API dan gunakan response sebagai sumber UI.
  Future<LeaveRequestResponse?> submit(LeaveFormData formData) async {
    if (state.isLoading) return null;

    state = const LeaveSubmitState(status: LeaveSubmitStatus.loading);

    try {
      final response = await _repository.submitLeaveForm(formData);
      state = LeaveSubmitState(
        status: LeaveSubmitStatus.success,
        response: response,
      );
      return response;
    } on LeaveRequestException catch (error) {
      state = LeaveSubmitState(
        status: LeaveSubmitStatus.error,
        errorMessage: error.message,
      );
      return null;
    } catch (_) {
      state = const LeaveSubmitState(
        status: LeaveSubmitStatus.error,
        errorMessage: 'Gagal mengirim pengajuan cuti.',
      );
      return null;
    }
  }

  void reset() {
    state = const LeaveSubmitState();
  }
}

class LeaveCancelNotifier extends StateNotifier<LeaveCancelState> {
  LeaveCancelNotifier(this._ref, this._repository)
    : super(const LeaveCancelState());

  final Ref _ref;
  final LeaveRepository _repository;

  Future<bool> cancel({required String leaveId, required String reason}) async {
    if (state.isLoading) return false;

    state = const LeaveCancelState(isLoading: true);
    try {
      await _repository.cancelLeave(leaveId: leaveId, reason: reason);
      await _refreshLeaveData();
      state = const LeaveCancelState();
      return true;
    } on LeaveCancelException catch (error) {
      state = LeaveCancelState(errorMessage: error.message);
      return false;
    } catch (_) {
      state = const LeaveCancelState(errorMessage: 'Gagal membatalkan cuti.');
      return false;
    }
  }

  Future<void> _refreshLeaveData() async {
    _ref.invalidate(leaveBalanceProvider);
    _ref.invalidate(leaveStatusesProvider);
    _ref.invalidate(activeLeaveRequestsProvider);
    _ref.invalidate(leaveHistoryRequestsProvider);
    _ref.invalidate(paginatedLeaveHistoryProvider);

    await Future.wait([
      _ignoreRefreshError(_ref.read(leaveBalanceProvider.future)),
      _ignoreRefreshError(_ref.read(leaveStatusesProvider.future)),
    ]);
  }

  Future<void> _ignoreRefreshError(Future<Object?> future) async {
    try {
      await future;
    } catch (_) {
      // Halaman pemakai provider tetap menampilkan error state saat dibuka.
    }
  }
}

class LeaveLetterDownloadNotifier
    extends StateNotifier<LeaveLetterDownloadState> {
  LeaveLetterDownloadNotifier(this._repository)
    : super(const LeaveLetterDownloadState());

  static const _downloadsChannel = MethodChannel('sakti_apps_fe/downloads');

  final LeaveRepository _repository;

  Future<bool> download(String leaveId) async {
    if (state.isLoading) return false;

    state = LeaveLetterDownloadState(processingId: leaveId);
    try {
      final download = await _repository.downloadLeaveLetter(leaveId);
      await _downloadsChannel.invokeMethod<void>('savePdfToDownloads', {
        'fileName': download.fileName,
        'bytes': Uint8List.fromList(download.bytes),
      });
      state = const LeaveLetterDownloadState();
      return true;
    } on LeaveDownloadException catch (error) {
      state = LeaveLetterDownloadState(errorMessage: error.message);
      return false;
    } on PlatformException catch (error) {
      debugPrint(
        'Leave letter save platform error: '
        'code=${error.code}, message=${error.message}, details=${error.details}',
      );
      state = LeaveLetterDownloadState(
        errorMessage: error.message ?? 'Gagal menyimpan surat ke Downloads.',
      );
      return false;
    } catch (_) {
      state = const LeaveLetterDownloadState(
        errorMessage: 'Gagal mengunduh surat.',
      );
      return false;
    }
  }
}
