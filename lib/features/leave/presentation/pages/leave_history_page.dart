import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../models/leave_history_model.dart';
import '../models/leave_request_status.dart';
import '../providers/leave_submit_provider.dart';
import '../widgets/leave_history_card.dart';
import '../widgets/leave_top_bar.dart';

class LeaveHistoryPage extends ConsumerStatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  ConsumerState<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends ConsumerState<LeaveHistoryPage> {
  LeaveHistoryStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final histories = ref.watch(leaveHistoryRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                  const SizedBox(width: 9),
                  HistoryFilterChip(
                    label: 'Dibatalkan',
                    isSelected: _selectedStatus == LeaveHistoryStatus.canceled,
                    onTap: () => setState(
                      () => _selectedStatus = LeaveHistoryStatus.canceled,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Expanded(
              child: histories.when(
                data: (requests) {
                  final filteredRequests = requests
                      .where(
                        (request) =>
                            _selectedStatus == null ||
                            request.historyStatus == _selectedStatus,
                      )
                      .toList();

                  if (filteredRequests.isEmpty) {
                    return const _LeaveHistoryMessage(
                      'Belum ada riwayat pengajuan',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: LeaveHistoryCard(
                          history: request.toHistoryModel(),
                          onTap: () => context.push(
                            RouteName.leaveStatus,
                            extra: LeaveStatusRouteData(
                              data: request.toStatusData(),
                              fallbackRoute: RouteName.leaveHistory,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const _LeaveHistoryMessage('Memuat riwayat pengajuan...'),
                error: (error, stackTrace) => const _LeaveHistoryMessage(
                  'Riwayat pengajuan belum dapat dimuat.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveHistoryMessage extends StatelessWidget {
  const _LeaveHistoryMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
