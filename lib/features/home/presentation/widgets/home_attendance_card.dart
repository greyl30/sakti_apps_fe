import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Card presensi hari ini
/// Menggunakan dummy state sementara
/// Akan diganti provider/backend nantinya
// TODO: Integrasikan dengan backend presensi.
class HomeAttendanceCard extends StatelessWidget {
  const HomeAttendanceCard({
    super.key,
    required this.isHoliday,
    required this.canCheckIn,
    required this.canCheckOut,
    required this.onCheckInTap,
    required this.onCheckOutTap,
    this.onScheduleTap,
  });

  final bool isHoliday;
  final bool canCheckIn;
  final bool canCheckOut;
  final VoidCallback onCheckInTap;
  final VoidCallback onCheckOutTap;
  final VoidCallback? onScheduleTap;

  @override
  Widget build(BuildContext context) {
    final todayLabel = _formatToday(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Presensi hari ini',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 50),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.gray),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onScheduleTap,
                      borderRadius: BorderRadius.circular(15),
                      child: _WorkScheduleBar(
                        todayLabel: todayLabel,
                        isHoliday: isHoliday,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: -10,
                child: Row(
                  children: [
                    Expanded(
                      child: _AttendanceActionButton(
                        label: 'Presensi Masuk',
                        icon: AppAssets.iconIn,
                        isEnabled: !isHoliday && canCheckIn,
                        onTap: onCheckInTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AttendanceActionButton(
                        label: 'Presensi Keluar',
                        icon: AppAssets.iconLogout,
                        isEnabled: !isHoliday && canCheckOut,
                        onTap: onCheckOutTap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatToday(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }
}

class _WorkScheduleBar extends StatelessWidget {
  const _WorkScheduleBar({required this.todayLabel, required this.isHoliday});

  final String todayLabel;
  final bool isHoliday;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.iconCalendar,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              todayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 0),
            child: Container(
              width: 1,
              height: 32,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(width: 11),
          SvgPicture.asset(
            AppAssets.iconJam,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 7),
          Text(
            isHoliday ? '-' : '08.00 - 16.30',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceActionButton extends StatelessWidget {
  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isEnabled
        ? AppColors.primaryRed
        : const Color(0xFFD0D4DA);
    final foregroundColor = Colors.white;

    return SizedBox(
      height: 51,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: foregroundColor),
          ],
        ),
      ),
    );
  }
}
