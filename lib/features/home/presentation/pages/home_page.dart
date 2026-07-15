import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../attendance/presentation/models/attendance_ui_state.dart';
import '../../../attendance/presentation/widgets/attendance_status_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../models/home_role.dart';
import '../widgets/home_attendance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_history_section.dart';
import '../widgets/home_role_section.dart';
import '../widgets/home_reminder_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data profil user login dari auth provider.
    final user = ref.watch(authProvider).user;
    final positionParts = [
      user?.levelJabatan ?? user?.peran,
      user?.divisi ?? user?.unit,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    // Dummy state presensi, nantinya diganti dari backend/provider.
    const attendanceState = dummyAttendanceUiState;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HomeHeader(
              userName: user?.namaLengkap ?? 'Pengguna',
              positionLabel: positionParts.isEmpty
                  ? '-'
                  : positionParts.join(' | '),
              onProfileTap: () => context.push(RouteName.profile),
              onNotificationTap: () => context.push(RouteName.notification),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeAttendanceCard(
                    isHoliday: attendanceState.isHoliday,
                    canCheckOut:
                        !attendanceState.isHoliday &&
                        attendanceState.hasClockIn,
                    onCheckInTap: () => _handleCheckInTap(
                      context,
                      isHoliday: attendanceState.isHoliday,
                    ),
                    onCheckOutTap: () => _handleCheckOutTap(
                      context,
                      isHoliday: attendanceState.isHoliday,
                      hasClockIn: attendanceState.hasClockIn,
                    ),
                  ),
                  const SizedBox(height: 20),
                  HomeReminderSection(
                    isHoliday: attendanceState.isHoliday,
                    onCheckInReminderTap: () => _handleCheckInTap(
                      context,
                      isHoliday: attendanceState.isHoliday,
                    ),
                    onCheckOutReminderTap: () => _handleCheckOutTap(
                      context,
                      isHoliday: attendanceState.isHoliday,
                      hasClockIn: attendanceState.hasClockIn,
                    ),
                  ),
                  HomeRoleSection(
                    role: currentRole,
                    onSeeAllTap: () => debugPrint('TODO: Lihat semua approval'),
                    onItemTap: () => debugPrint('TODO: Buka detail approval'),
                  ),
                  const SizedBox(height: 20),
                  HomeHistorySection(
                    onSeeAllTap: () => context.push(RouteName.history),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  void _handleCheckInTap(BuildContext context, {required bool isHoliday}) {
    if (isHoliday) {
      _showHolidayDialog(context);
      return;
    }

    context.push(RouteName.checkInVerification);
  }

  void _handleCheckOutTap(
    BuildContext context, {
    required bool isHoliday,
    required bool hasClockIn,
  }) {
    if (isHoliday) {
      _showHolidayDialog(context);
      return;
    }

    if (!hasClockIn) {
      _showCheckOutUnavailableDialog(context);
      return;
    }

    context.push(RouteName.checkOutVerification);
  }

  void _showHolidayDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AttendanceStatusDialog(
        icon: AppAssets.iconInfo,
        title: 'Hari Ini Adalah Hari Libur',
        description:
            'Halaman presensi tidak tersedia,\nAnda tidak perlu melakukan presensi',
        buttonText: 'Tutup',
        onPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _showCheckOutUnavailableDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AttendanceStatusDialog(
        icon: AppAssets.iconInfo,
        title: 'Presensi Keluar Belum Tersedia',
        description: 'Presensi keluar hanya dapat\ndilakukan mulai pukul 17.00',
        buttonText: 'Tutup',
        onPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}
