import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/hrd_leave_finalization.dart';
import '../models/manager_leave_approval.dart';
import '../providers/hrd_leave_finalization_provider.dart';
import '../widgets/hrd_leave_finalization_widgets.dart';

class HrdLeaveFinalizationListPage extends ConsumerStatefulWidget {
  const HrdLeaveFinalizationListPage({super.key});

  @override
  ConsumerState<HrdLeaveFinalizationListPage> createState() =>
      _HrdLeaveFinalizationListPageState();
}

class _HrdLeaveFinalizationListPageState
    extends ConsumerState<HrdLeaveFinalizationListPage> {
  ManagerApprovalType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final finalizations = ref.watch(hrdPendingLeaveFinalizationsProvider);
    final actionState = ref.watch(hrdLeaveFinalizationActionProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar daftar finalisasi HRD.
            const LeaveTopBar(
              title: 'Finalisasi Cuti',
              subtitle: 'Finalisasi permohonan cuti karyawan',
              fallbackRoute: RouteName.home,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HistoryFilterChip(
                      label: 'Semua',
                      isSelected: _selectedType == null,
                      onTap: () => setState(() => _selectedType = null),
                    ),
                    const SizedBox(width: 8),
                    HistoryFilterChip(
                      label: 'Izin',
                      isSelected:
                          _selectedType == ManagerApprovalType.permission,
                      onTap: () => setState(
                        () => _selectedType = ManagerApprovalType.permission,
                      ),
                    ),
                    const SizedBox(width: 8),
                    HistoryFilterChip(
                      label: 'Cuti Sakit',
                      isSelected:
                          _selectedType == ManagerApprovalType.sickLeave,
                      onTap: () => setState(
                        () => _selectedType = ManagerApprovalType.sickLeave,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _refreshFinalizations,
                child: finalizations.when(
                  data: (items) {
                    final filtered = _selectedType == null
                        ? items
                        : items
                              .where(
                                (finalization) =>
                                    finalization.type == _selectedType,
                              )
                              .toList();

                    if (filtered.isEmpty) {
                      return const _HrdFinalizationMessageList(
                        'Belum ada pengajuan cuti menunggu finalisasi',
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final finalization = filtered[index];
                        final isProcessing = actionState.isProcessing(
                          finalization.id,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: HrdFinalizationCard(
                            finalization: finalization,
                            isProcessing: isProcessing,
                            onFinalize: isProcessing
                                ? null
                                : () => _finalizeLeave(finalization),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const _HrdFinalizationMessageList(
                    'Memuat finalisasi cuti...',
                  ),
                  error: (error, stackTrace) =>
                      const _HrdFinalizationMessageList(
                        'Finalisasi cuti belum dapat dimuat.',
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshFinalizations() async {
    ref.invalidate(hrdPendingLeaveFinalizationsProvider);

    try {
      await ref.read(hrdPendingLeaveFinalizationsProvider.future);
    } catch (_) {
      // Error state tetap ditampilkan oleh provider.
    }
  }

  Future<void> _finalizeLeave(HrdLeaveFinalization finalization) async {
    final isSuccess = await ref
        .read(hrdLeaveFinalizationActionProvider.notifier)
        .finalize(finalization.id);
    if (!mounted) return;

    if (!isSuccess) {
      final message = ref.read(hrdLeaveFinalizationActionProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Gagal melakukan finalisasi cuti.'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => HrdFinalizationSuccessDialog(
        onOkPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}

class _HrdFinalizationMessageList extends StatelessWidget {
  const _HrdFinalizationMessageList(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 220),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
