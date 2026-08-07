import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/manager_leave_approval.dart';
import '../providers/manager_leave_approval_provider.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class ManagerLeaveRejectReasonPage extends ConsumerStatefulWidget {
  const ManagerLeaveRejectReasonPage({super.key, required this.approval});

  final ManagerLeaveApproval approval;

  @override
  ConsumerState<ManagerLeaveRejectReasonPage> createState() =>
      _ManagerLeaveRejectReasonPageState();
}

class _ManagerLeaveRejectReasonPageState
    extends ConsumerState<ManagerLeaveRejectReasonPage> {
  final _reasonController = TextEditingController();
  String? _reasonError;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onReasonChanged);
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonChanged() {
    if (_reasonError != null && _reasonController.text.trim().isNotEmpty) {
      _reasonError = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(managerLeaveApprovalActionProvider);
    final isProcessing = actionState.isProcessing(widget.approval.id);
    final hasReason = _reasonController.text.trim().isNotEmpty;

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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    enabled: !actionState.isLoading,
                    minLines: 3,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Tambahkan keterangan',
                      errorText: _reasonError,
                      hintStyle: const TextStyle(
                        color: Color(0xFFB0B4BC),
                        fontSize: 14,
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
                    label: isProcessing ? 'Memproses...' : 'Selesai',
                    isPrimary: true,
                    onPressed: actionState.isLoading || !hasReason
                        ? null
                        : _rejectLeave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rejectLeave() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _reasonError = 'Alasan penolakan wajib diisi.');
      return;
    }

    setState(() => _reasonError = null);
    final isSuccess = await ref
        .read(managerLeaveApprovalActionProvider.notifier)
        .reject(leaveId: widget.approval.id, reason: reason);
    if (!mounted) return;

    if (!isSuccess) {
      final message = ref.read(managerLeaveApprovalActionProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Gagal menolak pengajuan cuti.'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

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
