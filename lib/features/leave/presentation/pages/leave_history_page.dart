import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
    final histories = ref.watch(paginatedLeaveHistoryProvider);
    final hasSupervisor = _hasSupervisor(
      ref.watch(authProvider).user?.atasanLangsungId,
    );

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
                child: _buildHistoryList(
                  context,
                  histories,
                  hasSupervisor: hasSupervisor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    PaginatedLeaveHistoryState histories, {
    required bool hasSupervisor,
  }) {
    if (histories.isLoading && histories.items.isEmpty) {
      return const _LeaveHistoryMessageList('Memuat riwayat pengajuan...');
    }

    if (histories.errorMessage != null && histories.items.isEmpty) {
      return _LeaveHistoryMessageList(histories.errorMessage!);
    }

    final filteredRequests = _uniqueRequests(histories.items)
        .where(
          (request) =>
              _selectedStatus == null ||
              request.historyStatus == _selectedStatus,
        )
        .toList();

    if (filteredRequests.isEmpty) {
      return const _LeaveHistoryMessageList('Belum ada riwayat pengajuan');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      itemCount: filteredRequests.length + (histories.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredRequests.length) {
          return _LoadMoreHistoryAction(
            isLoading: histories.isLoadingMore,
            onTap: () =>
                ref.read(paginatedLeaveHistoryProvider.notifier).loadMore(),
          );
        }

        final request = filteredRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: LeaveHistoryCard(
            history: request.toHistoryModel(),
            onTap: () => _openHistoryRequest(
              context,
              request,
              hasSupervisor: hasSupervisor,
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshHistories() async {
    ref.invalidate(leaveStatusesProvider);
    ref.invalidate(leaveHistoryRequestsProvider);
    await ref.read(paginatedLeaveHistoryProvider.notifier).refresh();
  }

  List<LeaveRequestResponse> _uniqueRequests(
    List<LeaveRequestResponse> requests,
  ) {
    final seenKeys = <String>{};
    final uniqueRequests = <LeaveRequestResponse>[];

    for (final request in requests) {
      final key = request.id.trim().isNotEmpty
          ? request.id
          : '${request.subType}-${request.startDate.toIso8601String()}-'
                '${request.endDate.toIso8601String()}-${request.status}';
      if (!seenKeys.add(key)) continue;

      uniqueRequests.add(request);
    }

    return uniqueRequests;
  }
}

class _LoadMoreHistoryAction extends StatelessWidget {
  const _LoadMoreHistoryAction({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Center(
        child: TextButton.icon(
          onPressed: isLoading ? null : onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondaryBlue,
                  ),
                )
              : const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          label: Text(
            isLoading ? 'Memuat...' : 'Muat Lebih Banyak',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

void _openHistoryRequest(
  BuildContext context,
  LeaveRequestResponse request, {
  required bool hasSupervisor,
}) {
  final statusData = request.toStatusData(
    skipsSupervisorApproval: !hasSupervisor,
  );

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

bool _hasSupervisor(String? supervisorId) {
  final trimmed = supervisorId?.trim();
  return trimmed != null && trimmed.isNotEmpty;
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
