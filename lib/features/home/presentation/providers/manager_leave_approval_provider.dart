import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/manager_leave_approval_remote_data_source.dart';
import '../../data/repositories/manager_leave_approval_repository.dart';
import '../models/manager_leave_approval.dart';

final managerLeaveApprovalRemoteDataSourceProvider =
    Provider<ManagerLeaveApprovalRemoteDataSource>((ref) {
      return ManagerLeaveApprovalRemoteDataSource(ApiClient.dio);
    });

final managerLeaveApprovalRepositoryProvider =
    Provider<ManagerLeaveApprovalRepository>((ref) {
      final remoteDataSource = ref.watch(
        managerLeaveApprovalRemoteDataSourceProvider,
      );
      return ManagerLeaveApprovalRepository(remoteDataSource);
    });

// TODO(Backend):
// Backend mengirim daftar pengajuan cuti status menunggu untuk role Atasan.
final managerPendingLeaveApprovalsProvider =
    FutureProvider<List<ManagerLeaveApproval>>((ref) async {
      final repository = ref.watch(managerLeaveApprovalRepositoryProvider);
      final approvals = await repository.getPendingApprovals();
      return approvals
          .map((approval) => approval.toPresentationModel())
          .toList();
    });

class ManagerLeaveApprovalActionState {
  const ManagerLeaveApprovalActionState({this.processingId, this.errorMessage});

  final String? processingId;
  final String? errorMessage;

  bool get isLoading => processingId != null;

  bool isProcessing(String leaveId) => processingId == leaveId;
}

final managerLeaveApprovalActionProvider =
    StateNotifierProvider<
      ManagerLeaveApprovalActionNotifier,
      ManagerLeaveApprovalActionState
    >((ref) {
      final repository = ref.watch(managerLeaveApprovalRepositoryProvider);
      return ManagerLeaveApprovalActionNotifier(ref, repository);
    });

class ManagerLeaveApprovalActionNotifier
    extends StateNotifier<ManagerLeaveApprovalActionState> {
  ManagerLeaveApprovalActionNotifier(this._ref, this._repository)
    : super(const ManagerLeaveApprovalActionState());

  final Ref _ref;
  final ManagerLeaveApprovalRepository _repository;

  Future<bool> approve(String leaveId) async {
    if (state.isLoading) return false;

    state = ManagerLeaveApprovalActionState(processingId: leaveId);
    try {
      await _repository.approveLeave(leaveId);
      _refreshApprovalList();
      state = const ManagerLeaveApprovalActionState();
      return true;
    } on ManagerLeaveApprovalException catch (error) {
      state = ManagerLeaveApprovalActionState(errorMessage: error.message);
      return false;
    } catch (_) {
      state = const ManagerLeaveApprovalActionState(
        errorMessage: 'Gagal menyetujui pengajuan cuti.',
      );
      return false;
    }
  }

  Future<bool> reject({required String leaveId, required String reason}) async {
    if (state.isLoading) return false;

    state = ManagerLeaveApprovalActionState(processingId: leaveId);
    try {
      await _repository.rejectLeave(leaveId: leaveId, reason: reason);
      _refreshApprovalList();
      state = const ManagerLeaveApprovalActionState();
      return true;
    } on ManagerLeaveApprovalException catch (error) {
      state = ManagerLeaveApprovalActionState(errorMessage: error.message);
      return false;
    } catch (_) {
      state = const ManagerLeaveApprovalActionState(
        errorMessage: 'Gagal menolak pengajuan cuti.',
      );
      return false;
    }
  }

  void _refreshApprovalList() {
    _ref.invalidate(managerPendingLeaveApprovalsProvider);
  }
}
