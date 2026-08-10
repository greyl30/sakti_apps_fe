import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(42),
        child: Ink(
          height: 51,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.primaryRed
                : const Color(0xFFFFF4F4),
            borderRadius: BorderRadius.circular(42),
            border: Border.all(
              color: isDestructive
                  ? AppColors.primaryRed
                  : const Color(0xFFF0B5B5),
              width: 1.4,
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDestructive ? Colors.white : AppColors.primaryRed,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
