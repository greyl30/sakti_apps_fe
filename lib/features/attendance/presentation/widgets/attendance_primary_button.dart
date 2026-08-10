import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AttendancePrimaryButton extends StatelessWidget {
  const AttendancePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLoadingLabel = _isLoadingButtonLabel(label);

    return SizedBox(
      width: double.infinity,
      height: 51,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLoadingLabel ? 13 : 16,
            fontWeight: FontWeight.w700,
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
