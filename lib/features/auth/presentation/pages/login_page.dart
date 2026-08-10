import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/login_rate_limit_service.dart';
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
  DateTime? _cooldownUntil;
  Duration _cooldownRemaining = Duration.zero;
  Timer? _cooldownTimer;

  bool get _isCoolingDown => _cooldownRemaining > Duration.zero;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkEmailCooldown);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.removeListener(_checkEmailCooldown);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    await _checkEmailCooldown();
    if (_isCoolingDown) return;

    // Validasi form login
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailController.text.trim();
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      email: email,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      await LoginRateLimitService.reset(email);
      if (!mounted) return;
      // Redirect ke homepage setelah login berhasil
      context.go(RouteName.home);
      return;
    }

    final cooldownUntil = await LoginRateLimitService.recordFailure(email);
    if (!mounted) return;
    if (cooldownUntil != null) {
      _startCooldown(cooldownUntil);
    }

    // Menampilkan snackbar ketika login gagal
    final errorMessage = ref.read(authProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cooldownUntil == null
              ? errorMessage ?? 'Email atau password salah'
              : 'Terlalu banyak percobaan gagal. Coba lagi dalam ${_formatCooldown(_cooldownRemaining)}.',
        ),
      ),
    );
  }

  Future<void> _checkEmailCooldown() async {
    final cooldownUntil = await LoginRateLimitService.cooldownUntil(
      _emailController.text,
    );
    if (!mounted) return;

    if (cooldownUntil == null) {
      _stopCooldown();
      return;
    }

    if (_cooldownUntil == cooldownUntil && _cooldownTimer?.isActive == true) {
      return;
    }

    _startCooldown(cooldownUntil);
  }

  void _startCooldown(DateTime cooldownUntil) {
    _cooldownUntil = cooldownUntil;
    _updateCooldownRemaining();
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCooldownRemaining();
    });
  }

  void _updateCooldownRemaining() {
    final cooldownUntil = _cooldownUntil;
    if (cooldownUntil == null) {
      _stopCooldown();
      return;
    }

    final remaining = cooldownUntil.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      final email = _emailController.text.trim();
      LoginRateLimitService.reset(email);
      _stopCooldown();
      return;
    }

    if (!mounted) return;
    setState(() {
      _cooldownRemaining = remaining;
    });
  }

  void _stopCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    if (!mounted) return;
    setState(() {
      _cooldownUntil = null;
      _cooldownRemaining = Duration.zero;
    });
  }

  String _formatCooldown(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 5 * 60);
    final minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsPart = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesPart:$secondsPart';
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
                    fontSize: 38,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                if (_isCoolingDown) ...[
                  Text(
                    'Coba lagi dalam ${_formatCooldown(_cooldownRemaining)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                AuthPrimaryButton(
                  label: 'Masuk',
                  isLoading: authState.isLoading,
                  onPressed: _isCoolingDown ? null : _submitLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
