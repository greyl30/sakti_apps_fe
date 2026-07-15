import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/leave_history_model.dart';
import 'leave_history_status_badge.dart';

class LeaveHistoryCard extends StatelessWidget {
  const LeaveHistoryCard({super.key, required this.history});

  final LeaveHistoryModel history;

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
                  history.leaveType,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  _formatDateRange(history.startDate, history.endDate),
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
          LeaveHistoryStatusBadge(status: history.status),
        ],
      ),
    );
  }
}

String _formatDateRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) return _formatDate(startDate);
  return '${startDate.day}-${_formatDate(endDate)}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
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
