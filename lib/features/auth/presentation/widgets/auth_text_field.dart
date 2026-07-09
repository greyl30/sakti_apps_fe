import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

// Widget input email/password reusable untuk halaman auth
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIconPadding,
    this.prefixIconSize = 22,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  // Mengatur padding icon depan
  final EdgeInsetsGeometry? prefixIconPadding;
  // Mengatur ukuran icon depan
  final double prefixIconSize;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.42),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Padding(
          padding: prefixIconPadding ?? EdgeInsets.zero,
          child: Icon(
            prefixIcon,
            size: prefixIconSize,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.secondaryBlue.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: AppColors.secondaryBlue.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.secondaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
      ),
    );
  }
}
