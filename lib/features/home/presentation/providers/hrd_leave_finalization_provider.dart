import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/hrd_leave_finalization_remote_data_source.dart';
import '../../data/repositories/hrd_leave_finalization_repository.dart';
import '../models/hrd_leave_finalization.dart';

final hrdLeaveFinalizationRemoteDataSourceProvider =
    Provider<HrdLeaveFinalizationRemoteDataSource>((ref) {
      return HrdLeaveFinalizationRemoteDataSource(ApiClient.dio);
    });

final hrdLeaveFinalizationRepositoryProvider =
    Provider<HrdLeaveFinalizationRepository>((ref) {
      final remoteDataSource = ref.watch(
        hrdLeaveFinalizationRemoteDataSourceProvider,
      );
      return HrdLeaveFinalizationRepository(remoteDataSource);
    });

// TODO(Backend):
// Backend mengirim daftar pengajuan cuti yang menunggu finalisasi HRD.
final hrdPendingLeaveFinalizationsProvider =
    FutureProvider<List<HrdLeaveFinalization>>((ref) async {
      final repository = ref.watch(hrdLeaveFinalizationRepositoryProvider);
      final finalizations = await repository.getFinalizations();
      return finalizations
          .map((finalization) => finalization.toPresentationModel())
          .toList();
    });

class HrdLeaveFinalizationActionState {
  const HrdLeaveFinalizationActionState({this.processingId, this.errorMessage});

  final String? processingId;
  final String? errorMessage;

  bool get isLoading => processingId != null;

  bool isProcessing(String leaveId) => processingId == leaveId;
}

final hrdLeaveFinalizationActionProvider =
    StateNotifierProvider<
      HrdLeaveFinalizationActionNotifier,
      HrdLeaveFinalizationActionState
    >((ref) {
      final repository = ref.watch(hrdLeaveFinalizationRepositoryProvider);
      return HrdLeaveFinalizationActionNotifier(ref, repository);
    });

class HrdLeaveFinalizationActionNotifier
    extends StateNotifier<HrdLeaveFinalizationActionState> {
  HrdLeaveFinalizationActionNotifier(this._ref, this._repository)
    : super(const HrdLeaveFinalizationActionState());

  final Ref _ref;
  final HrdLeaveFinalizationRepository _repository;

  Future<bool> finalize(String leaveId) async {
    if (state.isLoading) return false;

    state = HrdLeaveFinalizationActionState(processingId: leaveId);
    try {
      await _repository.finalizeLeave(leaveId);
      _refreshFinalizationList();
      state = const HrdLeaveFinalizationActionState();
      return true;
    } on HrdLeaveFinalizationException catch (error) {
      state = HrdLeaveFinalizationActionState(errorMessage: error.message);
      return false;
    } catch (_) {
      state = const HrdLeaveFinalizationActionState(
        errorMessage: 'Gagal melakukan finalisasi cuti.',
      );
      return false;
    }
  }

  void _refreshFinalizationList() {
    _ref.invalidate(hrdPendingLeaveFinalizationsProvider);
  }
}
