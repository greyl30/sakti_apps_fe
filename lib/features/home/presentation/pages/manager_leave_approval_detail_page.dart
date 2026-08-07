import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/manager_leave_approval.dart';
import '../providers/manager_leave_approval_provider.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class ManagerLeaveApprovalDetailPage extends ConsumerWidget {
  const ManagerLeaveApprovalDetailPage({super.key, required this.approval});

  final ManagerLeaveApproval approval;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(managerLeaveApprovalActionProvider);
    final isProcessing = actionState.isProcessing(approval.id);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar detail pengajuan atasan.
            const LeaveTopBar(
              title: 'Detail Pengajuan',
              subtitle: 'Tinjau pengajuan sebelum menyetujui',
              fallbackRoute: RouteName.managerLeaveApprovals,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  ManagerApprovalEmployeeCard(approval: approval),
                  const SizedBox(height: 22),
                  ManagerApprovalDetailCard(approval: approval),
                  const SizedBox(height: 24),
                  ManagerApprovalButton(
                    label: isProcessing ? 'Memproses...' : 'Setujui Cuti',
                    isPrimary: true,
                    onPressed: actionState.isLoading
                        ? null
                        : () => _approveLeave(context, ref),
                  ),
                  const SizedBox(height: 16),
                  ManagerApprovalButton(
                    label: 'Tolak Cuti',
                    isPrimary: false,
                    onPressed: actionState.isLoading
                        ? null
                        : () => context.push(
                            RouteName.managerLeaveRejectReason,
                            extra: approval,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveLeave(BuildContext context, WidgetRef ref) async {
    final isSuccess = await ref
        .read(managerLeaveApprovalActionProvider.notifier)
        .approve(approval.id);
    if (!context.mounted) return;

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
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(RouteName.managerLeaveApprovals);
        },
      ),
    );
  }
}
