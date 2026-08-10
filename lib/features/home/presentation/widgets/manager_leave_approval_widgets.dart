import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_success_widgets.dart';
import '../models/manager_leave_approval.dart';

class ManagerApprovalCard extends StatelessWidget {
  const ManagerApprovalCard({
    super.key,
    required this.approval,
    required this.onApprove,
    required this.onReject,
    this.isProcessing = false,
  });

  final ManagerLeaveApproval approval;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval.employeeName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      approval.division,
                      style: const TextStyle(
                        color: Color(0xFF8A8F98),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(
                  RouteName.managerLeaveApprovalDetail,
                  extra: approval,
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: AppColors.secondaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoPill(label: managerApprovalTypeLabel(approval.type)),
              const SizedBox(width: 10),
              _InfoPill(
                icon: AppAssets.iconCalendar,
                label:
                    '${_formatShortDateRange(approval.startDate, approval.endDate)} - ${approval.totalDays} hari',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            approval.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5F6972),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ApprovalActionButton(
                  label: isProcessing ? '...' : 'Tolak',
                  isPrimary: false,
                  onPressed: onReject,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ApprovalActionButton(
                  label: isProcessing ? '...' : 'Setujui',
                  isPrimary: true,
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ManagerApprovalEmployeeCard extends StatelessWidget {
  const ManagerApprovalEmployeeCard({super.key, required this.approval});

  final ManagerLeaveApproval approval;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC6E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            approval.employeeName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            approval.division,
            style: const TextStyle(
              color: Color(0xFF8A8F98),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ManagerApprovalDetailCard extends StatelessWidget {
  const ManagerApprovalDetailCard({super.key, required this.approval});

  final ManagerLeaveApproval approval;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAIL PENGAJUAN CUTI',
            style: TextStyle(
              color: Color(0xFF8A8F98),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 18),
          LeaveSummaryRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Mulai',
            value: _formatLongDate(approval.startDate),
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Selesai',
            value: _formatLongDate(approval.endDate),
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconDurasi,
            label: 'Durasi',
            value: '${approval.totalDays} hari kerja',
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconSisa,
            label: 'Sisa Cuti',
            value: approval.remainingLeave == null
                ? '-'
                : '${approval.remainingLeave} hari',
          ),
          LeaveSummaryRow(
            icon: AppAssets.iconAlasan,
            label: 'Alasan',
            value: approval.reason,
          ),
        ],
      ),
    );
  }
}

class ManagerApprovalButton extends StatelessWidget {
  const ManagerApprovalButton({
    super.key,
    required this.label,
    required this.isPrimary,
    required this.onPressed,
    this.height = 51,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _ApprovalActionButton(
        label: label,
        isPrimary: isPrimary,
        height: height,
        borderRadius: 24,
        onPressed: onPressed,
      ),
    );
  }
}

class ManagerApprovalSuccessDialog extends StatelessWidget {
  const ManagerApprovalSuccessDialog({
    super.key,
    required this.title,
    required this.onOkPressed,
  });

  final String title;
  final VoidCallback onOkPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8FD),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.iconCheck,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.secondaryBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 18),
            ManagerApprovalButton(
              label: 'OK',
              isPrimary: true,
              onPressed: onOkPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class ManagerRejectConfirmationDialog extends StatelessWidget {
  const ManagerRejectConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

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
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE7E7),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.iconInfo,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Apakah Anda yakin ingin\nmenolak pengajuan cuti ini?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ApprovalActionButton(
                    label: 'Ya',
                    isPrimary: false,
                    height: 51,
                    onPressed: onConfirm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ApprovalActionButton(
                    label: 'Tidak',
                    isPrimary: true,
                    height: 51,
                    onPressed: onCancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, this.icon});

  final String label;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC6E6F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon!,
              width: 15,
              height: 15,
              colorFilter: const ColorFilter.mode(
                AppColors.secondaryBlue,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalActionButton extends StatelessWidget {
  const _ApprovalActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
    this.height = 47,
    this.borderRadius = 22,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final isLoadingLabel = _isLoadingButtonLabel(label);
    final activeBackgroundColor = isPrimary
        ? const Color(0xFFD33B32)
        : const Color(0xFFFFE7E7);
    final activeForegroundColor = isPrimary
        ? Colors.white
        : AppColors.primaryRed;
    final activeBorderColor = isPrimary
        ? const Color(0xFFD33B32)
        : const Color(0xFFF1BDBD);
    final disabledColor = const Color(0xFFD0D4DA);

    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: activeBackgroundColor,
          disabledBackgroundColor: disabledColor,
          foregroundColor: activeForegroundColor,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isEnabled ? activeBorderColor : disabledColor,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isLoadingLabel ? 13 : 16,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

bool _isLoadingButtonLabel(String label) {
  final normalized = label.trim().toLowerCase();
  return normalized.startsWith('memuat') ||
      normalized.startsWith('mengirim') ||
      normalized.startsWith('memproses') ||
      normalized.startsWith('mengunduh') ||
      normalized.startsWith('mengambil') ||
      normalized.startsWith('loading');
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
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
  );
}

String _formatShortDateRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) return _formatShortDate(startDate);
  return '${startDate.day} - ${_formatShortDate(endDate)}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatShortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
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
