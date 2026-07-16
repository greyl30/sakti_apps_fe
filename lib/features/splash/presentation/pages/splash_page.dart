import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/splash_bottom_button.dart';
import '../widgets/splash_content.dart';
import '../widgets/splash_indicator.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<SplashItem> _items = const [
    SplashItem(
      image: AppAssets.splash1,
      title: 'Presensi Semudah Selfie',
      description:
          'Aplikasi resmi untuk presensi harian dan manajemen cuti karyawan KOPFETEL Malang',
    ),
    SplashItem(
      image: AppAssets.splash2,
      title: 'Fitur Cuti dan Dispensasi',
      description:
          'Ajukan cuti atau dispensasi kapan saja, dengan notifikasi langsung ke WhatsApp',
    ),
    SplashItem(
      image: AppAssets.splash3,
      title: 'Unduh Surat Cuti Langsung',
      description:
          'Surat cuti bertanda tangan resmi dari atasan siap diunduh kapan saja dengan cepat',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSession();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final hasSession = await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;

    context.go(hasSession ? RouteName.home : RouteName.login);
  }

  void _goToLogin() {
    context.go(RouteName.login);
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePrimaryButton() {
    if (_currentPage == _items.length - 1) {
      _goToLogin();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 18, 30, 30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentHeight = (constraints.maxHeight * .78)
                  .clamp(470.0, 540.0)
                  .toDouble();

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: Stack(
                        children: [
                          if (_currentPage > 0)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: _goToPreviousPage,
                                child: SvgPicture.asset(
                                  AppAssets.back2,
                                  width: 40.36,
                                  height: 40.36,
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _goToLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black.withValues(
                                  alpha: .72,
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lewati',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: contentHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _items.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return SplashContent(item: _items[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 56),
                    SplashIndicator(
                      currentIndex: _currentPage,
                      itemCount: _items.length,
                    ),
                    const SizedBox(height: 28),
                    SplashBottomButton(
                      label: isLastPage ? 'Masuk' : 'Selanjutnya',
                      onPrimaryPressed: _handlePrimaryButton,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
