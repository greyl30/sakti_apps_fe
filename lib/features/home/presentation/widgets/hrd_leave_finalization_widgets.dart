import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/hrd_leave_finalization.dart';
import '../models/manager_leave_approval.dart';
import 'manager_leave_approval_widgets.dart';

class HrdFinalizationCard extends StatelessWidget {
  const HrdFinalizationCard({
    super.key,
    required this.finalization,
    required this.onFinalize,
  });

  final HrdLeaveFinalization finalization;
  final VoidCallback onFinalize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finalization.employeeName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      finalization.division,
                      style: const TextStyle(
                        color: Color(0xFF8A8F98),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(
                  RouteName.hrdLeaveFinalizationDetail,
                  extra: finalization,
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: AppColors.secondaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoPill(label: managerApprovalTypeLabel(finalization.type)),
              const SizedBox(width: 8),
              _InfoPill(
                icon: AppAssets.iconCalendar,
                label:
                    '${_formatShortDateRange(finalization.startDate, finalization.endDate)} - ${finalization.totalDays} hari',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ManagerApprovalButton(
            label: 'Finalisasi',
            isPrimary: true,
            onPressed: onFinalize,
          ),
        ],
      ),
    );
  }
}

class HrdFinalizationSuccessDialog extends StatelessWidget {
  const HrdFinalizationSuccessDialog({super.key, required this.onOkPressed});

  final VoidCallback onOkPressed;

  @override
  Widget build(BuildContext context) {
    return ManagerApprovalSuccessDialog(
      title: 'Berhasil melakukan finalisasi!',
      onOkPressed: onOkPressed,
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
      height: 20,
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
              width: 10,
              height: 10,
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
              fontSize: 8,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatShortDateRange(DateTime startDate, DateTime endDate) {
  return '${startDate.day} - ${endDate.day} Jul 2026';
}
