import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../widgets/change_password_success_dialog.dart';
import '../widgets/password_text_field.dart';

class ChangePasswordPlaceholderPage extends ConsumerStatefulWidget {
  const ChangePasswordPlaceholderPage({super.key});

  @override
  ConsumerState<ChangePasswordPlaceholderPage> createState() =>
      _ChangePasswordPlaceholderPageState();
}

class _ChangePasswordPlaceholderPageState
    extends ConsumerState<ChangePasswordPlaceholderPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await ref
        .read(authProvider.notifier)
        .changePassword(
          currentPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;

    if (!success) {
      final errorMessage = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Gagal mengubah password.')),
      );
      return;
    }

    final successMessage =
        ref.read(authProvider).successMessage ??
        'Password berhasil diubah. Silakan login kembali.';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ChangePasswordSuccessDialog(
        title: successMessage,
        buttonLabel: 'Kembali ke Login',
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(RouteName.login);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar ubah password.
            const LeaveTopBar(
              title: 'Ubah Password',
              subtitle: 'Isi form berikut untuk mengubah password',
              fallbackRoute: RouteName.profile,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field password lama.
                      PasswordTextField(
                        label: 'Password Lama',
                        controller: _oldPasswordController,
                        obscureText: _obscureOldPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureOldPassword = !_obscureOldPassword;
                          });
                        },
                        validator: PasswordValidator.required(
                          'Password lama wajib diisi',
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Field password baru.
                      PasswordTextField(
                        label: 'Password Baru',
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        validator: (value) => _validateNewPassword(
                          value,
                          _oldPasswordController.text,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Field konfirmasi password baru.
                      PasswordTextField(
                        label: 'Konfirmasi Password Baru',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (value) => PasswordValidator.confirmation(
                          value,
                          _newPasswordController.text,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Tombol ubah password.
                      AuthPrimaryButton(
                        label: 'Kirim',
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading
                            ? null
                            : _submitChangePassword,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              context.push(RouteName.forgotPassword),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondaryBlue,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateNewPassword(String? value, String currentPassword) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password baru wajib diisi';
    if (password.length < 8) return 'Password baru minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password baru harus memiliki huruf besar';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password baru harus memiliki huruf kecil';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password baru harus memiliki angka';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(password)) {
      return 'Password baru harus memiliki karakter khusus';
    }
    if (password == currentPassword) {
      return 'Password baru tidak boleh sama dengan password lama';
    }
    return null;
  }
}
