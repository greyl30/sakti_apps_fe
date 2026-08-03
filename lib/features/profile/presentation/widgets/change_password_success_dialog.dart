import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';

class ChangePasswordSuccessDialog extends StatelessWidget {
  const ChangePasswordSuccessDialog({
    super.key,
    required this.title,
    required this.onOkPressed,
    this.buttonLabel = 'OK',
  });

  final String title;
  final VoidCallback onOkPressed;
  final String buttonLabel;

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
            // Icon sukses ubah password.
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8FD),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.iconCheck,
                width: 36,
                height: 36,
                colorFilter: const ColorFilter.mode(
                  AppColors.secondaryBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            LeavePrimaryButton(label: buttonLabel, onPressed: onOkPressed),
          ],
        ),
      ),
    );
  }
}
