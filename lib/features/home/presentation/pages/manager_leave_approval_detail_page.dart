import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/manager_leave_approval.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class ManagerLeaveApprovalDetailPage extends StatelessWidget {
  const ManagerLeaveApprovalDetailPage({super.key, required this.approval});

  final ManagerLeaveApproval approval;

  @override
  Widget build(BuildContext context) {
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
                    label: 'Setujui Cuti',
                    isPrimary: true,
                    onPressed: () => _showApproveDialog(context),
                  ),
                  const SizedBox(height: 16),
                  ManagerApprovalButton(
                    label: 'Tolak Cuti',
                    isPrimary: false,
                    onPressed: () => _showRejectDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    removeManagerApproval(approval.id);
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

  void _showRejectDialog(BuildContext context) {
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
