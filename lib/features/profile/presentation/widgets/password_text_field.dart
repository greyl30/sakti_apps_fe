import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.secondaryBlue.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            suffixIcon: IconButton(
              // Toggle show/hide password.
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 21,
                color: Colors.black.withValues(alpha: 0.46),
              ),
            ),
            enabledBorder: _border(
              AppColors.secondaryBlue.withValues(alpha: 0.22),
            ),
            focusedBorder: _border(AppColors.secondaryBlue),
            errorBorder: _border(AppColors.primaryRed),
            focusedErrorBorder: _border(AppColors.primaryRed),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: color),
    );
  }
}

class PasswordValidator {
  const PasswordValidator._();

  static String? Function(String?) required(String message) {
    return (value) {
      if (value == null || value.isEmpty) return message;
      return null;
    };
  }

  static String? confirmation(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != newPassword) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }
}
