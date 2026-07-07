import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // Validasi form login
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Redirect ke homepage setelah login berhasil
      context.go(RouteName.home);
      return;
    }

    // Menampilkan snackbar ketika login gagal
    final errorMessage = ref.read(authProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage ?? 'Email atau password salah')),
    );
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 56),
                  const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Masukkan email dan password Anda untuk\nmengakses layanan dengan aman',
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
                    prefixIconSize: 22,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Widget input password
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_rounded,
                    prefixIconPadding: const EdgeInsets.only(left: 15),
                    prefixIconSize: 22,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      // Toggle show/hide password
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        size: 21,
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.black.withValues(alpha: 0.46),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => context.push(RouteName.forgotPassword),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondaryBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lupa Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  AuthPrimaryButton(
                    label: 'Masuk',
                    isLoading: authState.isLoading,
                    onPressed: _submitLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
