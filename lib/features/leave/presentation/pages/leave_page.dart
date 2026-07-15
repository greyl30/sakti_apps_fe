import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../models/leave_request_status.dart';
import '../widgets/leave_cards.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_top_bar.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2,
                    children: const [
                      LeaveBalanceCard(
                        value: '12',
                        title: 'Sisa cuti 2026',
                        subtitle: '',
                        isWarning: true,
                      ),
                      LeaveBalanceCard(
                        value: '2',
                        title: 'Sisa cuti 2025',
                        subtitle: 'Berlaku s/d 31 Maret 2026',
                        isWarning: true,
                      ),
                      LeaveBalanceCard(
                        value: '3',
                        title: 'Digunakan',
                        subtitle: '',
                        isWarning: false,
                      ),
                      LeaveBalanceCard(
                        value: '13',
                        title: 'Total cuti tersedia',
                        subtitle: '',
                        isWarning: false,
                      ),
                    ],
                  ),
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
