import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../widgets/attendance_flow_app_bar.dart';
import '../widgets/attendance_info_tile.dart';
import '../widgets/attendance_primary_button.dart';

class CheckInConfirmationPage extends StatelessWidget {
  const CheckInConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar halaman konfirmasi
            const AttendanceFlowAppBar(
              title: 'Konfirmasi Presensi',
              subtitle: 'Konfirmasi presensi masuk Anda',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card ringkasan presensi
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: _cardDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RINGKASAN PRESENSI MASUK',
                          style: TextStyle(
                            color: Color(0xFF8A8F98),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                        SizedBox(height: 15),
                        AttendanceInfoTile(
                          icon: AppAssets.iconJam,
                          label: 'Waktu Masuk',
                          value: '08:00 WIB',
                        ),
                        SizedBox(height: 15),
                        AttendanceInfoTile(
                          icon: AppAssets.iconCalendar,
                          label: 'Tanggal',
                          value: 'Senin, 23 Juni 2025',
                        ),
                        SizedBox(height: 15),
                        AttendanceInfoTile(
                          icon: AppAssets.iconLokasi,
                          label: 'Lokasi',
                          value: 'Kantor KOPFETEL Malang',
                        ),
                        SizedBox(height: 15),
                        AttendanceInfoTile(
                          icon: AppAssets.iconGps,
                          label: 'Jarak',
                          value: '145m dari pusat kantor',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Card status tepat waktu
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC3E5F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            AppAssets.iconCheck,
                            width: 25,
                            height: 25,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF4C9CB2),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 17),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waktu 08:00',
                                style: TextStyle(
                                  color: Color(0xFF4C9CB2),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Presensi akan dicatat sebagai "TEPAT WAKTU"',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF8A8F98),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Tombol konfirmasi
                  AttendancePrimaryButton(
                    label: 'Konfirmasi Presensi Masuk',
                    onPressed: () => context.go(RouteName.checkInSuccess),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE7E8EC)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .06),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
