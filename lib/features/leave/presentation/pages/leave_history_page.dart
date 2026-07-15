import 'package:flutter/material.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../models/leave_history_model.dart';
import '../widgets/leave_history_card.dart';
import '../widgets/leave_top_bar.dart';

class LeaveHistoryPage extends StatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  State<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends State<LeaveHistoryPage> {
  LeaveHistoryStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    // TODO(Backend):
    // Ambil data riwayat pengajuan cuti dari API.
    final histories = dummyLeaveHistories;
    final filteredHistories = _selectedStatus == null
        ? histories
        : histories
              .where((history) => history.status == _selectedStatus)
              .toList();

    // TODO(UI):
    // Tambahkan Empty State ketika riwayat pengajuan kosong.
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman riwayat pengajuan.
            const LeaveTopBar(
              title: 'Riwayat Pengajuan',
              subtitle: 'Riwayat seluruh pengajuan cuti Anda',
              fallbackRoute: RouteName.leave,
            ),
            const SizedBox(height: 22),
            // Filter status riwayat pengajuan.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  HistoryFilterChip(
                    label: 'Semua',
                    isSelected: _selectedStatus == null,
                    onTap: () => setState(() => _selectedStatus = null),
                  ),
                  const SizedBox(width: 9),
                  HistoryFilterChip(
                    label: 'Disetujui',
                    isSelected: _selectedStatus == LeaveHistoryStatus.approved,
                    onTap: () => setState(
                      () => _selectedStatus = LeaveHistoryStatus.approved,
                    ),
                  ),
                  const SizedBox(width: 9),
                  HistoryFilterChip(
                    label: 'Ditolak',
                    isSelected: _selectedStatus == LeaveHistoryStatus.rejected,
                    onTap: () => setState(
                      () => _selectedStatus = LeaveHistoryStatus.rejected,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                itemCount: filteredHistories.length,
                itemBuilder: (context, index) {
                  final history = filteredHistories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: LeaveHistoryCard(history: history),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
