import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Section pengingat presensi pada homepage.
class HomeReminderSection extends StatelessWidget {
  const HomeReminderSection({
    super.key,
    required this.isHoliday,
    required this.onCheckInReminderTap,
    required this.onCheckOutReminderTap,
    this.checkInDeadlineLabel,
  });

  final bool isHoliday;
  final VoidCallback onCheckInReminderTap;
  final VoidCallback onCheckOutReminderTap;
  final String? checkInDeadlineLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Pengingat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 13),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.gray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 14,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: isHoliday
                ? [
                    _ReminderTile(
                      title: 'Hari ini adalah hari libur',
                      subtitle: 'Anda tidak perlu melakukan presensi',
                      onTap: onCheckInReminderTap,
                    ),
                  ]
                : [
                    _ReminderTile(
                      title: 'Lengkapi Presensi Masuk',
                      subtitle: checkInDeadlineLabel == null
                          ? 'Segera lakukan presensi masuk'
                          : 'Segera lakukan sebelum pukul $checkInDeadlineLabel',
                      onTap: onCheckInReminderTap,
                    ),
                    const Divider(
                      height: 1,
                      indent: 18,
                      endIndent: 18,
                      color: AppColors.gray,
                    ),
                    _ReminderTile(
                      title: 'Jangan Lupa Presensi Keluar',
                      subtitle: 'Lakukan tepat saat pulang',
                      onTap: onCheckOutReminderTap,
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14.5, 12, 14.5),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                AppAssets.iconPengingat,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryRed,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(-15, 0),
              child: SvgPicture.asset(
                AppAssets.iconNext,
                width: 13,
                height: 13,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF9B9B9B),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
