import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    // Validasi email lupa password
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted) return;

    final authState = ref.read(authProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? authState.successMessage ??
                    'Link reset password telah dikirim ke email Anda.'
              : authState.errorMessage ?? 'Server sedang tidak tersedia.',
        ),
      ),
    );

    if (success) {
      // Kembali ke Login setelah link reset password dikirim
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 70, 28, 24),
          child: Form(
              key: _formKey,
              child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: SvgPicture.asset(
                        AppAssets.iconBack,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

            const Text(
              'Lupa Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Masukkan email untuk menerima link dan\nmendapatkan kembali akses ke akun Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                  const SizedBox(height: 42),
                  // Widget input email
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Alamat email',
                    prefixIcon: Icons.email_rounded,
                    prefixIconPadding: const EdgeInsets.only(left: 15),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 35),
                  AuthPrimaryButton(
                    label: 'Kirim',
                    isLoading: authState.isLoading,
                    onPressed: _sendResetLink,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
