import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/attendance_history_model.dart';
import 'status_badge.dart';

class HistoryAttendanceCard extends StatelessWidget {
  const HistoryAttendanceCard({super.key, required this.history});

  final AttendanceHistoryModel history;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.fromLTRB(18, 17, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _attendanceTypeLabel(history.attendanceType),
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${_formatDate(history.date)} | ${history.time} WIB',
                  style: const TextStyle(
                    color: AppColors.secondaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusBadge(status: history.status),
        ],
      ),
    );
  }
}

String _attendanceTypeLabel(AttendanceHistoryType type) {
  return switch (type) {
    AttendanceHistoryType.clockIn => 'Presensi Masuk',
    AttendanceHistoryType.clockOut => 'Presensi Keluar',
  };
}

String _formatDate(DateTime date) {
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
