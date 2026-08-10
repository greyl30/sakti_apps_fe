import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../history/presentation/providers/attendance_history_provider.dart';
import '../../../leave/presentation/providers/leave_submit_provider.dart';
import '../utils/attendance_availability.dart';
import '../widgets/attendance_status_dialog.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  static final AttendanceRepository _attendanceRepository =
      AttendanceRepository(AttendanceRemoteDataSource(ApiClient.dio));

  void _backToHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteName.home);
  }

  void _startCheckIn(
    BuildContext context, {
    required AttendanceUnavailableReason? unavailableReason,
  }) {
    if (unavailableReason != null) {
      _showUnavailableDialog(context, unavailableReason);
      return;
    }

    context.push(RouteName.checkInVerification);
  }

  Future<void> _startCheckOut(
    BuildContext context, {
    required AttendanceUnavailableReason? unavailableReason,
  }) async {
    if (unavailableReason != null) {
      _showUnavailableDialog(context, unavailableReason);
      return;
    }

    final canCheckOut = await _canCheckOutByWorkConfig(context);
    if (!context.mounted) return;
    if (!canCheckOut) return;

    context.push(RouteName.checkOutVerification);
  }

  Future<bool> _canCheckOutByWorkConfig(BuildContext context) async {
    try {
      final config = await _attendanceRepository.getWorkConfig();
      if (!context.mounted) return false;
      final now = DateTime.now();
      if (now.isBefore(config.minimumClockOutDateTime(now))) {
        _showCheckOutUnavailableDialog(context);
        return false;
      }

      return true;
    } catch (_) {
      if (!context.mounted) return false;
      _showCheckOutUnavailableDialog(context);
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(attendanceHistoriesProvider);
    final holidays = ref.watch(activeLeaveHolidayDatesProvider);
    final leaveStatuses = ref.watch(leaveStatusesProvider);
    final availability = buildAttendanceAvailability(
      date: DateTime.now(),
      holidays: holidays.valueOrNull ?? const <DateTime>{},
      leaveRequests: leaveStatuses.valueOrNull ?? const [],
      histories: histories.valueOrNull,
    );

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header halaman
            _AttendanceHeader(onBackPressed: () => _backToHome(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                children: [
                  // Card Presensi Masuk
                  _AttendanceOptionCard(
                    title: 'Presensi Masuk',
                    subtitle: 'Klik untuk mulai',
                    icon: AppAssets.iconIn,
                    backgroundColor: const Color(0xFFFFEAEA),
                    borderColor: const Color(0xFFE9B7B7),
                    iconBackgroundColor: const Color(0xFFF3C3C3),
                    foregroundColor: AppColors.primaryRed,
                    isEnabled: availability.canCheckIn,
                    onTap: () => _startCheckIn(
                      context,
                      unavailableReason: availability.checkInUnavailableReason,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Card Presensi Keluar
                  _AttendanceOptionCard(
                    title: 'Presensi Keluar',
                    subtitle: 'Klik untuk mulai',
                    icon: AppAssets.iconLogout,
                    backgroundColor: const Color(0xFFEFFAFF),
                    borderColor: const Color(0xFFB7DCE9),
                    iconBackgroundColor: const Color(0xFFC3E5F0),
                    foregroundColor: AppColors.secondaryBlue,
                    isEnabled: availability.canCheckOut,
                    onTap: () => _startCheckOut(
                      context,
                      unavailableReason: availability.checkOutUnavailableReason,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  void _showUnavailableDialog(
    BuildContext context,
    AttendanceUnavailableReason reason,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AttendanceStatusDialog(
        icon: AppAssets.iconInfo,
        title: reason.title,
        description: reason.message,
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

class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(30, 18, 24, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBackPressed,
            borderRadius: BorderRadius.circular(22),
            child: SvgPicture.asset(AppAssets.iconBack, width: 41, height: 41),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presensi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pilih jenis presensi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceOptionCard extends StatelessWidget {
  const _AttendanceOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.foregroundColor,
    required this.isEnabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color foregroundColor;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isEnabled ? backgroundColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isEnabled ? borderColor : const Color(0xFFDADDE2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isEnabled ? iconBackgroundColor : AppColors.gray,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    isEnabled ? foregroundColor : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isEnabled
                            ? foregroundColor
                            : const Color(0xFFB7BBC2),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isEnabled
                            ? foregroundColor
                            : const Color(0xFF8F949C),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
