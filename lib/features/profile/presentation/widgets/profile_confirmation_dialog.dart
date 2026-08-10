import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileConfirmationDialog extends StatelessWidget {
  const ProfileConfirmationDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.isConfirmLoading = false,
    this.isCancelLoading = false,
  });

  final String icon;
  final String title;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isConfirmLoading;
  final bool isCancelLoading;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 346,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE7E7),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: confirmText,
                    isPrimary: false,
                    isLoading: isConfirmLoading,
                    onPressed: isConfirmLoading || isCancelLoading
                        ? null
                        : onConfirm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: cancelText,
                    isPrimary: true,
                    isLoading: isCancelLoading,
                    onPressed: isConfirmLoading || isCancelLoading
                        ? null
                        : onCancel,
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

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
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
      height: 51,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: activeBackgroundColor,
          disabledBackgroundColor: disabledColor,
          foregroundColor: activeForegroundColor,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
            side: BorderSide(
              color: isEnabled ? activeBorderColor : disabledColor,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: isPrimary ? Colors.white : AppColors.primaryRed,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
      ),
    );
  }
}
