import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';

/// Widget card presensi hari ini
/// Saat ini menggunakan dummy state
/// Akan diganti provider/backend nantinya
class HomeAttendanceCard extends StatelessWidget {
  const HomeAttendanceCard({
    super.key,
    required this.isCheckedIn,
    required this.canCheckOut,
    required this.onAttendanceTap,
  });

  final bool isCheckedIn;
  final bool canCheckOut;
  final VoidCallback onAttendanceTap;

  @override
  Widget build(BuildContext context) {
    final todayLabel = _formatToday(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Presensi hari ini',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE1E1E1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE23F36),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.iconCalendar,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        todayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      AppAssets.iconJam,
                      width: 17,
                      height: 17,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      '08.00 - 16.30',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _AttendanceActionButton(
                      label: 'Presensi Masuk',
                      icon: AppAssets.iconIn,
                      isEnabled: !isCheckedIn,
                      onTap: onAttendanceTap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AttendanceActionButton(
                      label: 'Presensi Keluar',
                      icon: AppAssets.iconOut,
                      isEnabled: canCheckOut,
                      onTap: onAttendanceTap,
                    ),
                  ),
                ],
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
        ? const Color(0xFFE23F36)
        : const Color(0xFFD1D5DB);
    final foregroundColor = isEnabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.75);

    return SizedBox(
      height: 42,
      child: FilledButton(
        onPressed: isEnabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
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
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 17, color: foregroundColor),
          ],
        ),
      ),
    );
  }
}
