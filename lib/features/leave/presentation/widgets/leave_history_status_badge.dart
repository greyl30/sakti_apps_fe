import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/leave_history_model.dart';

class LeaveHistoryStatusBadge extends StatelessWidget {
  const LeaveHistoryStatusBadge({super.key, required this.status});

  final LeaveHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final badge = _LeaveHistoryBadgeStyle.fromStatus(status);

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

class _LeaveHistoryBadgeStyle {
  const _LeaveHistoryBadgeStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  factory _LeaveHistoryBadgeStyle.fromStatus(LeaveHistoryStatus status) {
    return switch (status) {
      LeaveHistoryStatus.approved => const _LeaveHistoryBadgeStyle(
        label: 'Disetujui',
        foreground: AppColors.secondaryBlue,
        background: Color(0xFFEAF8FD),
        border: Color(0xFFC6E6F0),
      ),
      LeaveHistoryStatus.rejected => const _LeaveHistoryBadgeStyle(
        label: 'Ditolak',
        foreground: AppColors.primaryRed,
        background: Color(0xFFFFE7E7),
        border: Color(0xFFF1BDBD),
      ),
      LeaveHistoryStatus.canceled => const _LeaveHistoryBadgeStyle(
        label: 'Dibatalkan',
        foreground: Color(0xFF8A8F98),
        background: Color(0xFFF3F4F6),
        border: Color(0xFFD8DCE2),
      ),
    };
  }
}
