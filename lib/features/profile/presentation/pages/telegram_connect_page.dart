import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../providers/telegram_provider.dart';

class TelegramConnectPage extends ConsumerStatefulWidget {
  const TelegramConnectPage({super.key});

  @override
  ConsumerState<TelegramConnectPage> createState() =>
      _TelegramConnectPageState();
}

class _TelegramConnectPageState extends ConsumerState<TelegramConnectPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _connectTelegram() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      _showMessage('Sesi login tidak ditemukan. Silakan login kembali.');
      return;
    }

    final verificationCode = _codeController.text.trim().toUpperCase();
    final success = await ref
        .read(telegramProvider(userId).notifier)
        .connect(verificationCode);

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      context.pop(true);
      return;
    }

    final errorMessage = ref.read(telegramProvider(userId)).errorMessage;
    _showMessage(errorMessage ?? 'Gagal menghubungkan Telegram.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider.select((state) => state.user?.id));
    final telegramState = userId == null
        ? const TelegramState()
        : ref.watch(telegramProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const LeaveTopBar(
              title: 'Koneksi Telegram',
              subtitle: 'Masukkan kode verifikasi',
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
                      const Text(
                        'Kode Verifikasi',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          constraints: const BoxConstraints(minHeight: 51),
                          hintText: 'SAKTI-A7F3',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B4BC),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E4E8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.primaryRed,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.primaryRed,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final code = value?.trim();
                          if (code == null || code.isEmpty) {
                            return 'Kode verifikasi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      AuthPrimaryButton(
                        label: 'Hubungkan Telegram',
                        isLoading: telegramState.isConnectLoading,
                        onPressed: telegramState.isConnectLoading
                            ? null
                            : _connectTelegram,
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
