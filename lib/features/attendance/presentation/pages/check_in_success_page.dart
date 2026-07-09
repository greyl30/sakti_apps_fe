import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../widgets/attendance_primary_button.dart';

class CheckInSuccessPage extends StatelessWidget {
  const CheckInSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 88, 24, 28),
                  child: Column(
                    children: [
                      // Halaman sukses presensi
                      Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDDD9),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppAssets.iconCheck,
                            width: 42,
                            height: 42,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8FD),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFC6E6F0)),
                        ),
                        child: const Text(
                          'TERSIMPAN',
                          style: TextStyle(
                            color: Color(0xFF4C9CB2),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Presensi Masuk Berhasil!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Presensi telah berhasil tercatat di dalam sistem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A8F98),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Card informasi presensi tersimpan
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8FD),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFC6E6F0)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Presensi Masuk Tercatat',
                              style: TextStyle(
                                color: Color(0xFF8A8F98),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '08:00 WIB',
                              style: TextStyle(
                                color: Color(0xFF4C9CB2),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 22),
                            _SuccessInfoRow(
                              icon: AppAssets.iconCalendar,
                              label: 'Tanggal',
                              value: 'Senin, 23 Juni 2025',
                            ),
                            SizedBox(height: 16),
                            _SuccessInfoRow(
                              icon: AppAssets.iconLokasi,
                              label: 'Lokasi',
                              value: 'Kantor KOPEGTEL Malang',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Tombol kembali ke beranda
                      AttendancePrimaryButton(
                        label: 'Kembali ke Beranda',
                        onPressed: () => context.go(RouteName.home),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

class _SuccessInfoRow extends StatelessWidget {
  const _SuccessInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            Color(0xFF4C9CB2),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5F6972),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF4C9CB2),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
