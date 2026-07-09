import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../widgets/attendance_flow_app_bar.dart';
import '../widgets/attendance_primary_button.dart';

class CheckInVerificationPage extends StatelessWidget {
  const CheckInVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar halaman verifikasi
            const AttendanceFlowAppBar(
              title: 'Presensi',
              subtitle: 'Verifikasi wajah dan lokasi',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Placeholder preview kamera
                  Container(
                    height: 258,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101318),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 78,
                            height: 100,
                            color: Colors.white.withValues(alpha: .04),
                          ),
                        ),
                        const _CameraCorner(alignment: Alignment.topLeft),
                        const _CameraCorner(alignment: Alignment.topRight),
                        const _CameraCorner(alignment: Alignment.bottomLeft),
                        const _CameraCorner(alignment: Alignment.bottomRight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Card Tips Verifikasi
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.iconTips,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF4C9CB2),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips Verifikasi',
                                style: TextStyle(
                                  color: Color(0xFF4C9CB2),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Pastikan pencahayaan cukup, wajah terlihat jelas, dan lokasi aktif.',
                                style: TextStyle(
                                  color: Color(0xFF6A7B83),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Tombol mulai verifikasi
                  AttendancePrimaryButton(
                    label: 'Mulai Verifikasi',
                    onPressed: () => context.push(RouteName.checkInLoading),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

class _CameraCorner extends StatelessWidget {
  const _CameraCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(42),
        child: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: isLeft
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                right: isLeft
                    ? BorderSide.none
                    : const BorderSide(color: Colors.white, width: 2),
                top: isTop
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                bottom: isTop
                    ? BorderSide.none
                    : const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
