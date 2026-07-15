import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/hrd_leave_finalization.dart';
import '../widgets/hrd_leave_finalization_widgets.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class HrdLeaveFinalizationDetailPage extends StatelessWidget {
  const HrdLeaveFinalizationDetailPage({super.key, required this.finalization});

  final HrdLeaveFinalization finalization;

  @override
  Widget build(BuildContext context) {
    final approvalView = finalization.toApprovalView();

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
                    label: 'Finalisasi Cuti',
                    isPrimary: true,
                    onPressed: () => _showFinalizeDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinalizeDialog(BuildContext context) {
    // TODO(Backend):
    // Kirim status finalisasi cuti ke backend.
    removeHrdFinalization(finalization.id);
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
