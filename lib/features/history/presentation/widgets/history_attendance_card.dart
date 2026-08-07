import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/attendance_history_model.dart';
import 'status_badge.dart';

class HistoryAttendanceCard extends StatelessWidget {
  const HistoryAttendanceCard({super.key, required this.activity});

  final AttendanceHistoryActivity activity;

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
                  activity.title,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${_formatDate(activity.date)} | ${activity.timeLabel} WIB',
                  style: const TextStyle(
                    color: AppColors.secondaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StatusBadge(status: activity.status),
        ],
      ),
    );
  }
}

class AttendanceHistoryActivity {
  const AttendanceHistoryActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.timeLabel,
    required this.status,
  });

  final String id;
  final String title;
  final DateTime date;
  final String timeLabel;
  final AttendanceHistoryStatus status;
}

List<AttendanceHistoryActivity> attendanceHistoryActivities(
  AttendanceHistoryModel history,
) {
  final activities = <AttendanceHistoryActivity>[];

  if (history.clockInTime != null) {
    activities.add(
      AttendanceHistoryActivity(
        id: '${history.id}-clock-in',
        title: 'Presensi Masuk',
        date: history.date,
        timeLabel: history.clockInLabel,
        status: history.isOvertime
            ? AttendanceHistoryStatus.onTime
            : history.status,
      ),
    );
  }

  if (history.clockOutTime != null) {
    activities.add(
      AttendanceHistoryActivity(
        id: '${history.id}-clock-out',
        title: 'Presensi Keluar',
        date: history.date,
        timeLabel: history.clockOutLabel,
        status: history.isOvertime
            ? AttendanceHistoryStatus.overtime
            : AttendanceHistoryStatus.onTime,
      ),
    );
  }

  return activities;
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
