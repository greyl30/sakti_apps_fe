import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/manager_leave_approval.dart';
import '../widgets/manager_leave_approval_widgets.dart';

class ManagerLeaveApprovalListPage extends StatefulWidget {
  const ManagerLeaveApprovalListPage({super.key});

  @override
  State<ManagerLeaveApprovalListPage> createState() =>
      _ManagerLeaveApprovalListPageState();
}

class _ManagerLeaveApprovalListPageState
    extends State<ManagerLeaveApprovalListPage> {
  ManagerApprovalType? _selectedType;

  @override
  Widget build(BuildContext context) {
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
                    label: 'Cuti Darurat',
                    isSelected:
                        _selectedType == ManagerApprovalType.emergencyLeave,
                    onTap: () => setState(
                      () => _selectedType = ManagerApprovalType.emergencyLeave,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<ManagerLeaveApproval>>(
                valueListenable: managerApprovalStore,
                builder: (context, approvals, _) {
                  final filtered = _selectedType == null
                      ? approvals
                      : approvals
                            .where((approval) => approval.type == _selectedType)
                            .toList();

                  // TODO(UI):
                  // Tambahkan empty state saat tidak ada pengajuan menunggu.
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final approval = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ManagerApprovalCard(
                          approval: approval,
                          onApprove: () => _showApproveDialog(approval),
                          onReject: () => _showRejectDialog(approval),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(ManagerLeaveApproval approval) {
    removeManagerApproval(approval.id);
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
