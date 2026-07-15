import 'package:flutter/material.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/hrd_leave_finalization.dart';
import '../models/manager_leave_approval.dart';
import '../widgets/hrd_leave_finalization_widgets.dart';

class HrdLeaveFinalizationListPage extends StatefulWidget {
  const HrdLeaveFinalizationListPage({super.key});

  @override
  State<HrdLeaveFinalizationListPage> createState() =>
      _HrdLeaveFinalizationListPageState();
}

class _HrdLeaveFinalizationListPageState
    extends State<HrdLeaveFinalizationListPage> {
  ManagerApprovalType? _selectedType;

  @override
  Widget build(BuildContext context) {
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
              child: ValueListenableBuilder<List<HrdLeaveFinalization>>(
                valueListenable: hrdFinalizationStore,
                builder: (context, finalizations, _) {
                  final filtered = _selectedType == null
                      ? finalizations
                      : finalizations
                            .where(
                              (finalization) =>
                                  finalization.type == _selectedType,
                            )
                            .toList();

                  // TODO(UI):
                  // Tambahkan empty state saat tidak ada finalisasi menunggu.
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final finalization = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: HrdFinalizationCard(
                          finalization: finalization,
                          onFinalize: () =>
                              _showFinalizeDialog(finalization.id),
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

  void _showFinalizeDialog(String id) {
    // TODO(Backend):
    // Kirim status finalisasi cuti ke backend.
    removeHrdFinalization(id);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => HrdFinalizationSuccessDialog(
        onOkPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}
