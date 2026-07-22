import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/leave_remote_data_source.dart';
import '../../data/models/leave_balance_model.dart';
import '../../data/models/leave_request_model.dart';
import '../../data/repositories/leave_repository.dart';
import '../models/leave_form_data.dart';

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
  return repository.getLeaveStatuses();
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
