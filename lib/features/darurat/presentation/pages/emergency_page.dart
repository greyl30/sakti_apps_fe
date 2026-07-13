import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../leave/presentation/models/leave_request_status.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header halaman Darurat
            const LeaveTopBar(
              title: 'Darurat',
              subtitle: 'Digunakan untuk kondisi mendadak',
              fallbackRoute: RouteName.home,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card Kirimkan Dispensasi
                  _EmergencyActionCard(
                    title: 'Kirimkan Dispensasi',
                    subtitle: 'Izin 2 hari tanpa mengurangi kuota cuti',
                    icon: Icons.add_rounded,
                    onTap: () => context.push(RouteName.emergencyDispensation),
                  ),
                  const SizedBox(height: 14),
                  // Card Ajukan Cuti Darurat
                  _EmergencyActionCard(
                    title: 'Ajukan Cuti Darurat',
                    subtitle: 'Cuti mendadak lebih dari 2 hari',
                    icon: Icons.medical_services_outlined,
                    onTap: () => context.push(RouteName.emergencyLeave),
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle('Pengajuan'),
                  const SizedBox(height: 12),
                  LeaveListItem(
                    title: 'Cuti Darurat',
                    subtitle: '2 - 4 Juli 2026',
                    status: 'Dalam Proses',
                    statusColor: AppColors.primaryRed,
                    icon: AppAssets.iconPending,
                    onTap: () => context.push(
                      RouteName.leaveStatus,
                      extra: LeaveStatusRouteData(
                        data: dummyEmergencyLeaveWaitingSupervisor,
                        fallbackRoute: RouteName.emergency,
                        bottomNavigationIndex: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionTitle('Riwayat Pengajuan'),
                      GestureDetector(
                        onTap: () => debugPrint('TODO: Lihat semua riwayat'),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const LeaveListItem(
                    title: 'Dispensasi',
                    subtitle: '25 Maret 2026',
                    status: 'Disetujui',
                    statusColor: AppColors.secondaryBlue,
                    icon: AppAssets.iconCheck,
                  ),
                  const SizedBox(height: 12),
                  const LeaveListItem(
                    title: 'Cuti Darurat',
                    subtitle: '16 - 19 Februari 2026',
                    status: 'Disetujui',
                    statusColor: AppColors.secondaryBlue,
                    icon: AppAssets.iconCheck,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }
}

class _EmergencyActionCard extends StatelessWidget {
  const _EmergencyActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFD33B32),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withValues(alpha: .18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryRed, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                AppAssets.iconNext,
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
