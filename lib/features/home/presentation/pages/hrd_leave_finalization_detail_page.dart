import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/hrd_leave_finalization.dart';
import '../providers/hrd_leave_finalization_provider.dart';
import '../widgets/hrd_leave_finalization_widgets.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class HrdLeaveFinalizationDetailPage extends ConsumerWidget {
  const HrdLeaveFinalizationDetailPage({super.key, required this.finalization});

  final HrdLeaveFinalization finalization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalView = finalization.toApprovalView();
    final actionState = ref.watch(hrdLeaveFinalizationActionProvider);
    final isProcessing = actionState.isProcessing(finalization.id);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar detail finalisasi HRD.
            const LeaveTopBar(
              title: 'Detail Pengajuan',
              subtitle: 'Tinjau pengajuan sebelum finalisasi',
              fallbackRoute: RouteName.hrdLeaveFinalizations,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  ManagerApprovalEmployeeCard(approval: approvalView),
                  const SizedBox(height: 22),
                  ManagerApprovalDetailCard(approval: approvalView),
                  const SizedBox(height: 24),
                  ManagerApprovalButton(
                    label: isProcessing ? 'Memproses...' : 'Finalisasi Cuti',
                    isPrimary: true,
                    onPressed: actionState.isLoading
                        ? null
                        : () => _finalizeLeave(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizeLeave(BuildContext context, WidgetRef ref) async {
    final isSuccess = await ref
        .read(hrdLeaveFinalizationActionProvider.notifier)
        .finalize(finalization.id);
    if (!context.mounted) return;

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
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(RouteName.hrdLeaveFinalizations);
        },
      ),
    );
  }
}
