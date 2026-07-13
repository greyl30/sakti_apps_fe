import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../leave/presentation/widgets/leave_success_widgets.dart';

class EmergencySummaryCard extends StatelessWidget {
  const EmergencySummaryCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul ringkasan agar mudah diganti ketika data backend tersedia.
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A8F98),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          LeaveSummaryRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Mulai',
            value: _formatLongDate(startDate),
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Selesai',
            value: _formatLongDate(endDate),
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconAlasan,
            label: 'Alasan',
            value: reason,
          ),
        ],
      ),
    );
  }
}

String formatEmergencyDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _formatLongDate(DateTime date) {
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
