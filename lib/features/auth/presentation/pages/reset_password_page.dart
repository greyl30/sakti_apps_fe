import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/widgets/change_password_success_dialog.dart';
import '../../../profile/presentation/widgets/password_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_primary_button.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitResetPassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final token = widget.token.trim();
    if (token.isEmpty) {
      _showMessage('Token reset password tidak valid.');
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(
          token: token,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;

    if (success) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => ChangePasswordSuccessDialog(
          title: 'Password berhasil diubah. Silakan login kembali.',
          buttonLabel: 'Kembali ke Login',
          onOkPressed: () {
            Navigator.of(dialogContext).pop();
            context.go(RouteName.login);
          },
        ),
      );
      return;
    }

    final errorMessage = ref.read(authProvider).errorMessage;
    _showMessage(errorMessage ?? 'Gagal mereset password.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final hasToken = widget.token.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 58, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Isi form berikut untuk mengubah password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.58),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                if (!hasToken) ...[
                  const _ResetPasswordErrorText(
                    'Token reset password tidak ditemukan. Silakan buka ulang link reset dari email.',
                  ),
                  const SizedBox(height: 22),
                ],
                PasswordTextField(
                  label: 'Password Baru',
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: _validateNewPassword,
                ),
                const SizedBox(height: 22),
                PasswordTextField(
                  label: 'Konfirmasi Password Baru',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    final confirmationError = PasswordValidator.confirmation(
                      value,
                      _newPasswordController.text,
                    );
                    if (confirmationError != null) return confirmationError;
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                AuthPrimaryButton(
                  label: 'Kirim',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _submitResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password baru wajib diisi';
    if (password.length < 8) return 'Password minimal 8 karakter';
    return null;
  }
}

class _ResetPasswordErrorText extends StatelessWidget {
  const _ResetPasswordErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: AppColors.primaryRed,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }
}
