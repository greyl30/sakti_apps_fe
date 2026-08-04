import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/storage/onboarding_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  bool _isCheckingStartup = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStartupFlow();
    });
  }

  Future<void> _checkStartupFlow() async {
    final hasCompletedOnboarding =
        await OnboardingStorageService.hasCompletedOnboarding();

    if (!mounted) return;

    if (!hasCompletedOnboarding) {
      setState(() {
        _isCheckingStartup = false;
      });
      return;
    }

    final hasSession = await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;

    context.go(hasSession ? RouteName.home : RouteName.login);
  }

  void _startOnboarding() {
    context.go(RouteName.splash);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: _isCheckingStartup
            ? const SizedBox.expand()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final logoSize = (constraints.maxHeight * .21)
                      .clamp(122.0, 166.0)
                      .toDouble();
                  final ctaHeight = (constraints.maxHeight * .12)
                      .clamp(74.0, 94.0)
                      .toDouble();
                  final overlayWidth = (constraints.maxWidth * .56)
                      .clamp(156.0, 218.0)
                      .toDouble();
                  final startButtonWidth = (constraints.maxWidth * .31)
                      .clamp(94.0, 132.0)
                      .toDouble();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(33, 22, 33, 24),
                    child: Column(
                      children: [
                        const Spacer(flex: 12),
                        SvgPicture.asset(
                          AppAssets.iconSaktilogo,
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'SAKTI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontFamily: 'StackSansHeadline',
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            height: .95,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hadir Tepat, Kerja Hebat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(flex: 16),
                        _WelcomeCtaArea(
                          height: ctaHeight,
                          overlayWidth: overlayWidth,
                          startButtonWidth: startButtonWidth,
                          onPressed: _startOnboarding,
                        ),
                        const Spacer(flex: 4),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _WelcomeCtaArea extends StatelessWidget {
  const _WelcomeCtaArea({
    required this.height,
    required this.overlayWidth,
    required this.startButtonWidth,
    required this.onPressed,
  });

  final double height;
  final double overlayWidth;
  final double startButtonWidth;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 25,
            right: 25,
            top: 0,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            top: -33,
            child: Container(
              width: overlayWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Kelola presensi dan cuti\ndalam satu aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 84,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    AppAssets.iconBackmulai,
                    width: startButtonWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
