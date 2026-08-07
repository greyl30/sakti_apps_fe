import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../../data/models/leave_request_model.dart';
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
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
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
                      isSelected:
                          _selectedStatus == LeaveHistoryStatus.approved,
                      onTap: () => setState(
                        () => _selectedStatus = LeaveHistoryStatus.approved,
                      ),
                    ),
                    const SizedBox(width: 9),
                    HistoryFilterChip(
                      label: 'Ditolak',
                      isSelected:
                          _selectedStatus == LeaveHistoryStatus.rejected,
                      onTap: () => setState(
                        () => _selectedStatus = LeaveHistoryStatus.rejected,
                      ),
                    ),
                    const SizedBox(width: 9),
                    HistoryFilterChip(
                      label: 'Dibatalkan',
                      isSelected:
                          _selectedStatus == LeaveHistoryStatus.canceled,
                      onTap: () => setState(
                        () => _selectedStatus = LeaveHistoryStatus.canceled,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _refreshHistories,
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
                      return const _LeaveHistoryMessageList(
                        'Belum ada riwayat pengajuan',
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: LeaveHistoryCard(
                            history: request.toHistoryModel(),
                            onTap: () => _openHistoryRequest(context, request),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const _LeaveHistoryMessageList(
                    'Memuat riwayat pengajuan...',
                  ),
                  error: (error, stackTrace) => const _LeaveHistoryMessageList(
                    'Riwayat pengajuan belum dapat dimuat.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshHistories() async {
    ref.invalidate(leaveStatusesProvider);
    ref.invalidate(leaveHistoryRequestsProvider);

    try {
      await ref.read(leaveStatusesProvider.future);
    } catch (_) {
      // Error state tetap ditampilkan oleh provider.
    }
  }
}

void _openHistoryRequest(BuildContext context, LeaveRequestResponse request) {
  final statusData = request.toStatusData();

  if (statusData.status == LeaveApprovalStatus.canceled) {
    context.push(
      RouteName.leaveCancelSuccess,
      extra: {'data': statusData, 'reason': request.cancelReason ?? ''},
    );
    return;
  }

  if (statusData.status == LeaveApprovalStatus.approved ||
      statusData.status == LeaveApprovalStatus.rejected) {
    context.push(RouteName.leaveSuccess, extra: statusData);
    return;
  }

  context.push(
    RouteName.leaveStatus,
    extra: LeaveStatusRouteData(
      data: statusData,
      fallbackRoute: RouteName.leaveHistory,
    ),
  );
}

class _LeaveHistoryMessageList extends StatelessWidget {
  const _LeaveHistoryMessageList(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 220),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
