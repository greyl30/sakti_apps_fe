import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../models/leave_request_status.dart';
import '../providers/leave_submit_provider.dart';
import '../widgets/leave_cards.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_top_bar.dart';

class LeavePage extends ConsumerWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(leaveBalanceProvider);
    final balanceData = balance.valueOrNull;
    final isBalanceLoading = balance.isLoading && balanceData == null;
    final balanceValueFallback = isBalanceLoading ? '...' : '-';
    final hasPreviousYearLeave =
        (balanceData?.previousYearRemainingLeave ?? 0) > 0;

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
              child: ListView(
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
                          title: 'Sisa cuti ${balanceData?.year ?? ''}',
                          subtitle: '',
                          isWarning: true,
                        ),
                        LeaveBalanceCard(
                          value:
                              balanceData?.previousYearRemainingLeave
                                  .toString() ??
                              balanceValueFallback,
                          title: 'Sisa cuti tahun lalu',
                          subtitle: '',
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
                          title: 'Sisa cuti ${balanceData?.year ?? ''}',
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
                  LeaveListItem(
                    title: 'Izin',
                    subtitle: '13 - 15 Juli 2026',
                    status: 'Dalam Proses',
                    statusColor: const Color(0xFF8A8F98),
                    icon: AppAssets.iconPending,
                    onTap: () => context.push(
                      RouteName.leaveStatus,
                      extra: dummyLeaveWaitingSupervisor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle(
                    title: 'Riwayat Pengajuan',
                    actionLabel: 'Lihat semua',
                    onActionTap: () => context.push(RouteName.leaveHistory),
                  ),
                  const SizedBox(height: 20),
                  const LeaveListItem(
                    title: 'Wawancara S2',
                    subtitle: '22 Mei 2026',
                    status: 'Disetujui',
                    statusColor: AppColors.secondaryBlue,
                    icon: AppAssets.iconCheck,
                  ),
                  const SizedBox(height: 12),
                  const LeaveListItem(
                    title: 'Acara keluarga',
                    subtitle: '16 - 19 Maret 2026',
                    status: 'Disetujui',
                    statusColor: AppColors.secondaryBlue,
                    icon: AppAssets.iconCheck,
                  ),
                  const SizedBox(height: 12),
                  const LeaveListItem(
                    title: 'Pengecekan kesehatan',
                    subtitle: '3 Januari 2026',
                    status: 'Ditolak',
                    statusColor: AppColors.primaryRed,
                    icon: AppAssets.iconNo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
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
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}
