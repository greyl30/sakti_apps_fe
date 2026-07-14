import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../widgets/change_password_success_dialog.dart';
import '../widgets/password_text_field.dart';

class ChangePasswordPlaceholderPage extends StatefulWidget {
  const ChangePasswordPlaceholderPage({super.key});

  @override
  State<ChangePasswordPlaceholderPage> createState() =>
      _ChangePasswordPlaceholderPageState();
}

class _ChangePasswordPlaceholderPageState
    extends State<ChangePasswordPlaceholderPage> {
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

  void _submitChangePassword() {
    // Validasi dasar form ubah password.
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // TODO(Backend):
    // Kirim request Change Password.
    // Verifikasi password lama.
    // Update password pada Supabase Auth melalui backend.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ChangePasswordSuccessDialog(
        title: 'Password berhasil diubah',
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(RouteName.profile);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        validator: PasswordValidator.required(
                          'Password baru wajib diisi',
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
                        label: 'Ubah Password',
                        isLoading: false,
                        onPressed: _submitChangePassword,
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
}
