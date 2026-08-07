import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../data/models/leave_request_model.dart';
import '../models/leave_request_status.dart';
import '../providers/leave_submit_provider.dart';
import '../widgets/leave_cards.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_top_bar.dart';

class LeavePage extends ConsumerStatefulWidget {
  const LeavePage({super.key});

  @override
  ConsumerState<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends ConsumerState<LeavePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Refresh saldo setelah halaman Cuti selesai dibuat agar tidak memakai cache lama.
      ref.invalidate(leaveBalanceProvider);
      // Refresh pengajuan pribadi agar role Atasan tidak melihat cache data approval bawahan.
      ref.invalidate(leaveStatusesProvider);
      ref.invalidate(activeLeaveRequestsProvider);
      ref.invalidate(leaveHistoryRequestsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(leaveBalanceProvider);
    final balanceData = balance.valueOrNull;
    final isBalanceLoading = balance.isLoading && balanceData == null;
    final balanceValueFallback = isBalanceLoading ? '...' : '-';
    final hasPreviousYearLeave =
        (balanceData?.previousYearRemainingLeave ?? 0) > 0;
    final currentLeaveYear = _leaveYearLabel(balanceData?.year);
    final previousYearValidUntil = _formatValidUntil(
      balanceData?.previousYearLeaveValidUntil,
    );
    final activeRequests = ref.watch(activeLeaveRequestsProvider);
    final historyRequests = ref.watch(leaveHistoryRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman Cuti
            const LeaveTopBar(
              title: 'Cuti',
              subtitle: 'Kelola dan ajukan cuti Anda',
              fallbackRoute: RouteName.home,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: _refreshLeaveData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  children: [
                    // Card ringkasan sisa cuti
                    if (hasPreviousYearLeave)
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.72,
                        children: [
                          LeaveBalanceCard(
                            value:
                                balanceData?.remainingLeave.toString() ??
                                balanceValueFallback,
                            title: 'Sisa cuti $currentLeaveYear',
                            subtitle: '',
                            isWarning: true,
                          ),
                          LeaveBalanceCard(
                            value:
                                balanceData?.previousYearRemainingLeave
                                    .toString() ??
                                balanceValueFallback,
                            title: 'Sisa cuti tahun lalu',
                            subtitle: previousYearValidUntil == null
                                ? ''
                                : 'Berlaku s.d. $previousYearValidUntil',
                            isWarning: true,
                          ),
                          LeaveBalanceCard(
                            value:
                                balanceData?.usedLeave.toString() ??
                                balanceValueFallback,
                            title: 'Digunakan',
                            subtitle: '',
                            isWarning: false,
                          ),
                          LeaveBalanceCard(
                            value:
                                balanceData?.totalLeave.toString() ??
                                balanceValueFallback,
                            title: 'Total cuti tersedia',
                            subtitle: '',
                            isWarning: false,
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LeaveBalanceCard(
                            value:
                                balanceData?.remainingLeave.toString() ??
                                balanceValueFallback,
                            title: 'Sisa cuti $currentLeaveYear',
                            subtitle: '',
                            isWarning: true,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: LeaveBalanceCard(
                                  value:
                                      balanceData?.usedLeave.toString() ??
                                      balanceValueFallback,
                                  title: 'Digunakan',
                                  subtitle: '',
                                  isWarning: false,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: LeaveBalanceCard(
                                  value:
                                      balanceData?.totalLeave.toString() ??
                                      balanceValueFallback,
                                  title: 'Total cuti tersedia',
                                  subtitle: '',
                                  isWarning: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (balance.hasError) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Saldo cuti belum dapat dimuat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A8F98),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 25),
                    // Tombol menuju form ajukan cuti
                    LeaveActionCard(
                      onTap: () => context.push(RouteName.leaveApply),
                    ),
                    const SizedBox(height: 30),
                    const _SectionTitle(title: 'Pengajuan'),
                    const SizedBox(height: 20),
                    activeRequests.when(
                      data: (requests) {
                        if (requests.isEmpty) {
                          return const _LeaveEmptyText(
                            'Belum ada pengajuan cuti aktif',
                          );
                        }

                        return Column(
                          children: [
                            for (
                              var index = 0;
                              index < requests.length;
                              index++
                            ) ...[
                              LeaveListItem(
                                title: requests[index].presentationType,
                                subtitle: _formatDateRange(
                                  requests[index].startDate,
                                  requests[index].endDate,
                                ),
                                status: requests[index].statusLabel,
                                statusColor: const Color(0xFF8A8F98),
                                icon: AppAssets.iconPending,
                                onTap: () => context.push(
                                  RouteName.leaveStatus,
                                  extra: requests[index].toStatusData(),
                                ),
                              ),
                              if (index != requests.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        );
                      },
                      loading: () =>
                          const _LeaveLoadingText('Memuat pengajuan cuti...'),
                      error: (error, stackTrace) => const _LeaveEmptyText(
                        'Pengajuan cuti belum dapat dimuat.',
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionTitle(
                      title: 'Riwayat Pengajuan',
                      actionLabel: 'Lihat semua',
                      onActionTap: () => context.push(RouteName.leaveHistory),
                    ),
                    const SizedBox(height: 20),
                    historyRequests.when(
                      data: (requests) {
                        if (requests.isEmpty) {
                          return const _LeaveEmptyText(
                            'Belum ada riwayat pengajuan',
                          );
                        }

                        final visibleRequests = requests.take(3).toList();
                        return Column(
                          children: [
                            for (
                              var index = 0;
                              index < visibleRequests.length;
                              index++
                            ) ...[
                              LeaveListItem(
                                title: visibleRequests[index].presentationType,
                                subtitle: _formatDateRange(
                                  visibleRequests[index].startDate,
                                  visibleRequests[index].endDate,
                                ),
                                status: visibleRequests[index].statusLabel,
                                statusColor: _historyStatusColor(
                                  visibleRequests[index].statusLabel,
                                ),
                                icon: _historyStatusIcon(
                                  visibleRequests[index].statusLabel,
                                ),
                                onTap: () => _openHistoryRequest(
                                  context,
                                  visibleRequests[index],
                                ),
                              ),
                              if (index != visibleRequests.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        );
                      },
                      loading: () => const _LeaveLoadingText(
                        'Memuat riwayat pengajuan...',
                      ),
                      error: (error, stackTrace) => const _LeaveEmptyText(
                        'Riwayat pengajuan belum dapat dimuat.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }

  Future<void> _refreshLeaveData() async {
    ref.invalidate(leaveBalanceProvider);
    ref.invalidate(leaveStatusesProvider);
    ref.invalidate(activeLeaveRequestsProvider);
    ref.invalidate(leaveHistoryRequestsProvider);

    await Future.wait([
      _ignoreRefreshError(ref.read(leaveBalanceProvider.future)),
      _ignoreRefreshError(ref.read(leaveStatusesProvider.future)),
    ]);
  }

  Future<void> _ignoreRefreshError(Future<Object?> future) async {
    try {
      await future;
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

  context.push(RouteName.leaveStatus, extra: statusData);
}

String _formatDateRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) return _formatDate(startDate);
  return '${startDate.day} - ${_formatDate(endDate)}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatDate(DateTime date) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _leaveYearLabel(int? year) {
  if (year == null || year <= 0) return DateTime.now().year.toString();
  return year.toString();
}

String? _formatValidUntil(DateTime? date) {
  if (date == null) return null;
  return _formatDate(date);
}

Color _historyStatusColor(String statusLabel) {
  final normalized = statusLabel.trim().toLowerCase();
  if (normalized == 'ditolak' || normalized == 'dibatalkan') {
    return AppColors.primaryRed;
  }

  return AppColors.secondaryBlue;
}

String _historyStatusIcon(String statusLabel) {
  final normalized = statusLabel.trim().toLowerCase();
  if (normalized == 'ditolak' || normalized == 'dibatalkan') {
    return AppAssets.iconNo;
  }

  return AppAssets.iconCheck;
}

class _LeaveLoadingText extends StatelessWidget {
  const _LeaveLoadingText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8A8F98),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LeaveEmptyText extends StatelessWidget {
  const _LeaveEmptyText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8A8F98),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondaryBlue,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}
