import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/emergency_history_model.dart';

class EmergencyHistoryStatusBadge extends StatelessWidget {
  const EmergencyHistoryStatusBadge({super.key, required this.status});

  final EmergencyHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final badge = _EmergencyHistoryBadgeStyle.fromStatus(status);

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

class _EmergencyHistoryBadgeStyle {
  const _EmergencyHistoryBadgeStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  factory _EmergencyHistoryBadgeStyle.fromStatus(
    EmergencyHistoryStatus status,
  ) {
    return switch (status) {
      EmergencyHistoryStatus.approved => const _EmergencyHistoryBadgeStyle(
        label: 'Disetujui',
        foreground: AppColors.secondaryBlue,
        background: Color(0xFFEAF8FD),
        border: Color(0xFFC6E6F0),
      ),
      EmergencyHistoryStatus.rejected => const _EmergencyHistoryBadgeStyle(
        label: 'Ditolak',
        foreground: AppColors.primaryRed,
        background: Color(0xFFFFE7E7),
        border: Color(0xFFF1BDBD),
      ),
    };
  }
}
