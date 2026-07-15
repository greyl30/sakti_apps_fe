import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/manager_leave_approval.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class ManagerLeaveRejectReasonPage extends StatefulWidget {
  const ManagerLeaveRejectReasonPage({super.key, required this.approval});

  final ManagerLeaveApproval approval;

  @override
  State<ManagerLeaveRejectReasonPage> createState() =>
      _ManagerLeaveRejectReasonPageState();
}

class _ManagerLeaveRejectReasonPageState
    extends State<ManagerLeaveRejectReasonPage> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar form alasan tolak.
            const LeaveTopBar(
              title: 'Alasan Tolak Cuti',
              subtitle: 'Tuliskan alasan penolakan cuti',
              fallbackRoute: RouteName.managerLeaveApprovalDetail,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  ManagerApprovalEmployeeCard(approval: widget.approval),
                  const SizedBox(height: 18),
                  ManagerApprovalDetailCard(approval: widget.approval),
                  const SizedBox(height: 22),
                  const Text(
                    'Isi Alasan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    minLines: 3,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Tambahkan keterangan',
                      hintStyle: const TextStyle(
                        color: Color(0xFFB0B4BC),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ManagerApprovalButton(
                    label: 'Selesai',
                    isPrimary: true,
                    onPressed: _showRejectedDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectedDialog() {
    // TODO(Backend):
    // Kirim status penolakan dan alasan ke backend.
    removeManagerApproval(widget.approval.id);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ManagerApprovalSuccessDialog(
        title: 'Pengajuan cuti berhasil ditolak',
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(RouteName.managerLeaveApprovals);
        },
      ),
    );
  }
}
