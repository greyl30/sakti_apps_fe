import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/manager_leave_approval.dart';
import '../providers/manager_leave_approval_provider.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class ManagerLeaveApprovalListPage extends ConsumerStatefulWidget {
  const ManagerLeaveApprovalListPage({super.key});

  @override
  ConsumerState<ManagerLeaveApprovalListPage> createState() =>
      _ManagerLeaveApprovalListPageState();
}

class _ManagerLeaveApprovalListPageState
    extends ConsumerState<ManagerLeaveApprovalListPage> {
  ManagerApprovalType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final approvals = ref.watch(managerPendingLeaveApprovalsProvider);
    final actionState = ref.watch(managerLeaveApprovalActionProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar daftar persetujuan atasan.
            const LeaveTopBar(
              title: 'Setujui Cuti',
              subtitle: 'Setujui permohonan cuti karyawan',
              fallbackRoute: RouteName.home,
            ),
            const SizedBox(height: 22),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  HistoryFilterChip(
                    label: 'Semua',
                    isSelected: _selectedType == null,
                    onTap: () => setState(() => _selectedType = null),
                  ),
                  const SizedBox(width: 8),
                  HistoryFilterChip(
                    label: 'Izin',
                    isSelected: _selectedType == ManagerApprovalType.permission,
                    onTap: () => setState(
                      () => _selectedType = ManagerApprovalType.permission,
                    ),
                  ),
                  const SizedBox(width: 8),
                  HistoryFilterChip(
                    label: 'Cuti Sakit',
                    isSelected: _selectedType == ManagerApprovalType.sickLeave,
                    onTap: () => setState(
                      () => _selectedType = ManagerApprovalType.sickLeave,
                    ),
                  ),
                  const SizedBox(width: 8),
                  HistoryFilterChip(
                    label: 'Dispensasi',
                    isSelected:
                        _selectedType == ManagerApprovalType.dispensation,
                    onTap: () => setState(
                      () => _selectedType = ManagerApprovalType.dispensation,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _refreshApprovals,
                child: approvals.when(
                  data: (items) {
                    final filtered = _selectedType == null
                        ? items
                        : items
                              .where(
                                (approval) => approval.type == _selectedType,
                              )
                              .toList();

                    if (filtered.isEmpty) {
                      return const _ManagerApprovalMessageList(
                        'Belum ada pengajuan cuti menunggu persetujuan',
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final approval = filtered[index];
                        final isProcessing = actionState.isProcessing(
                          approval.id,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: ManagerApprovalCard(
                            approval: approval,
                            isProcessing: isProcessing,
                            onApprove: isProcessing
                                ? null
                                : () => _approveLeave(approval),
                            onReject: isProcessing
                                ? null
                                : () => _showRejectDialog(approval),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const _ManagerApprovalMessageList(
                    'Memuat pengajuan cuti...',
                  ),
                  error: (error, stackTrace) =>
                      const _ManagerApprovalMessageList(
                        'Pengajuan cuti belum dapat dimuat.',
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshApprovals() async {
    ref.invalidate(managerPendingLeaveApprovalsProvider);

    try {
      await ref.read(managerPendingLeaveApprovalsProvider.future);
    } catch (_) {
      // Error state tetap ditampilkan oleh provider.
    }
  }

  Future<void> _approveLeave(ManagerLeaveApproval approval) async {
    final isSuccess = await ref
        .read(managerLeaveApprovalActionProvider.notifier)
        .approve(approval.id);
    if (!mounted) return;

    if (!isSuccess) {
      final message = ref.read(managerLeaveApprovalActionProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Gagal menyetujui pengajuan cuti.'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ManagerApprovalSuccessDialog(
        title: 'Berhasil melakukan persetujuan!',
        onOkPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _showRejectDialog(ManagerLeaveApproval approval) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ManagerRejectConfirmationDialog(
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          context.push(RouteName.managerLeaveRejectReason, extra: approval);
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}

class _ManagerApprovalMessageList extends StatelessWidget {
  const _ManagerApprovalMessageList(this.message);

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
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
