import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

// Tombol bawah onboarding untuk navigasi lanjut/masuk
class SplashBottomButton extends StatelessWidget {
  const SplashBottomButton({
    super.key,
    required this.label,
    required this.onPrimaryPressed,
  });

  final String label;
  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPrimaryPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
