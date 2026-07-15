import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/attendance_history_model.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final AttendanceHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final badge = _BadgeStyle.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badge.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badge.border),
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          color: badge.foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  factory _BadgeStyle.fromStatus(AttendanceHistoryStatus status) {
    return switch (status) {
      AttendanceHistoryStatus.onTime => const _BadgeStyle(
        label: 'Tepat Waktu',
        foreground: AppColors.secondaryBlue,
        background: Color(0xFFEAF8FD),
        border: Color(0xFFC6E6F0),
      ),
      AttendanceHistoryStatus.late => const _BadgeStyle(
        label: 'Terlambat',
        foreground: AppColors.primaryRed,
        background: Color(0xFFFFE7E7),
        border: Color(0xFFF1BDBD),
      ),
      AttendanceHistoryStatus.overtime => const _BadgeStyle(
        label: 'Lembur',
        foreground: AppColors.primaryRed,
        background: Color(0xFFFFE7E7),
        border: Color(0xFFF1BDBD),
      ),
    };
  }
}
