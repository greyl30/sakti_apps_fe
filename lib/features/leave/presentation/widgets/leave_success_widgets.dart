import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/leave_request_status.dart';
import 'leave_list_item.dart';

class LeaveSuccessHeader extends StatelessWidget {
  const LeaveSuccessHeader({
    super.key,
    required this.title,
    required this.description,
    this.badge = 'TERSIMPAN',
  });

  final String title;
  final String description;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon berhasil
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDDD9),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppAssets.iconCheck,
              width: 42,
              height: 42,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC6E6F0)),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: AppColors.secondaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class LeaveSummaryCard extends StatelessWidget {
  const LeaveSummaryCard({super.key, required this.data, this.cancelReason});

  final LeaveRequestStatusData data;
  final String? cancelReason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          LeaveSummaryRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Mulai',
            value: _formatLongDate(data.startDate),
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Selesai',
            value: _formatLongDate(data.endDate),
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconDurasi,
            label: 'Durasi',
            value: '${data.totalDays} hari kerja',
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconSisa,
            label: 'Sisa Cuti',
            value: '6 hari',
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconAlasan,
            label: 'Alasan',
            value: data.reason,
          ),
          if (cancelReason != null)
            LeaveSummaryRow(
              icon: AppAssets.iconAlasan,
              label: 'Alasan pembatalan',
              value: cancelReason!,
            ),
        ],
      ),
    );
  }
}

class LeaveSummaryRow extends StatelessWidget {
  const LeaveSummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.secondaryBlue,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8A8F98),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
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

class LeaveSecondaryButton extends StatelessWidget {
  const LeaveSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFFE7E7),
          foregroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFF1BDBD)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class LeaveConfirmationDialog extends StatelessWidget {
  const LeaveConfirmationDialog({
    super.key,
    required this.title,
    this.description,
    required this.onOkPressed,
  });

  final String title;
  final String? description;
  final VoidCallback onOkPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.iconCheck, width: 42, height: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 10),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 22),
            LeavePrimaryButton(label: 'OK', onPressed: onOkPressed),
          ],
        ),
      ),
    );
  }
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
