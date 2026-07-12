import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../models/attendance_flow_type.dart';
import '../widgets/attendance_flow_app_bar.dart';
import '../widgets/attendance_info_tile.dart';
import '../widgets/attendance_primary_button.dart';

class CheckInConfirmationPage extends StatelessWidget {
  const CheckInConfirmationPage({super.key, required this.flowType});

  final AttendanceFlowType flowType;

  Future<void> _handleConfirm(BuildContext context) async {
    if (flowType.isCheckIn) {
      context.go(RouteName.checkInSuccess);
      return;
    }

    // Popup lembur untuk flow Presensi Keluar.
    final isOvertime = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _OvertimeDialog(),
    );

    if (!context.mounted) return;
    context.go(RouteName.checkOutSuccess, extra: isOvertime == true);
  }

  @override
  Widget build(BuildContext context) {
    // Dummy status terlambat sementara sampai validasi backend tersedia.
    const isLate = true;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar halaman konfirmasi
            AttendanceFlowAppBar(
              title: flowType.confirmationTitle,
              subtitle: flowType.confirmationSubtitle,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card ringkasan presensi
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flowType.summaryTitle,
                          style: const TextStyle(
                            color: Color(0xFF8A8F98),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ..._summaryTiles(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Card status tepat waktu atau terlambat
                  _StatusCard(
                    isLate: flowType.isCheckIn && isLate,
                    timeLabel: flowType.isCheckIn ? '09:10' : '16:30',
                    description: flowType.isCheckIn && isLate
                        ? 'Presensi akan dicatat sebagai Terlambat'
                        : flowType.isCheckIn
                        ? 'Presensi akan dicatat sebagai Tepat Waktu'
                        : 'Presensi keluar akan dicatat',
                  ),
                  if (flowType.isCheckIn && isLate) ...[
                    const SizedBox(height: 18),
                    // Form alasan keterlambatan
                    const Text(
                      'Isi Alasan Keterlambatan (wajib)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      minLines: 3,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Tulis keterangan...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFB0B4BC),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E4E8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 25),
                  // Tombol konfirmasi
                  AttendancePrimaryButton(
                    label: flowType.confirmButtonLabel,
                    onPressed: () => _handleConfirm(context),
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

  List<Widget> _summaryTiles() {
    final items = flowType.isCheckIn
        ? const [
            AttendanceInfoTile(
              icon: AppAssets.iconJam,
              label: 'Waktu Masuk',
              value: '09:10 WIB',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconCalendar,
              label: 'Tanggal',
              value: 'Senin, 23 Juni 2025',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconLokasi,
              label: 'Lokasi',
              value: 'Kantor KOPEGTEL Malang',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconGps,
              label: 'Jarak',
              value: '200m dari pusat kantor',
            ),
          ]
        : const [
            AttendanceInfoTile(
              icon: AppAssets.iconIn,
              label: 'Jam Masuk',
              value: '08:00 WIB',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconOut,
              label: 'Jam Keluar',
              value: '17:05 WIB',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconDurasi,
              label: 'Total Jam Kerja',
              value: '9 jam 5 menit',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconCalendar,
              label: 'Tanggal',
              value: 'Senin, 23 Juni 2025',
            ),
            AttendanceInfoTile(
              icon: AppAssets.iconLokasi,
              label: 'Lokasi',
              value: 'Kantor KOPEGTEL Malang',
            ),
          ];

    return [
      for (var index = 0; index < items.length; index++) ...[
        if (index > 0) const SizedBox(height: 15),
        items[index],
      ],
    ];
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isLate,
    required this.timeLabel,
    required this.description,
  });

  final bool isLate;
  final String timeLabel;
  final String description;

  @override
  Widget build(BuildContext context) {
    final color = isLate ? const Color(0xFFD43B32) : const Color(0xFF4C9CB2);
    final backgroundColor = isLate
        ? const Color(0xFFFFECEC)
        : const Color(0xFFEAF8FD);
    final borderColor = isLate
        ? const Color(0xFFF0B7B7)
        : const Color(0xFFC6E6F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: SvgPicture.asset(
              AppAssets.iconCheck,
              width: 19,
              height: 19,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waktu $timeLabel',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text.rich(
                  TextSpan(
                    text: description.contains('sebagai')
                        ? '${description.split(' sebagai ').first} sebagai '
                        : description,
                    style: const TextStyle(
                      color: Color(0xFF6E7480),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                    children: description.contains('sebagai')
                        ? [
                            TextSpan(
                              text: description.split(' sebagai ').last,
                              style: const TextStyle(
                                color: Color(0xFF444A55),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OvertimeDialog extends StatelessWidget {
  const _OvertimeDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      backgroundColor: Colors.transparent,
      child: Center(
        // Popup lembur
        child: Container(
          width: 346,
          height: 230,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              SvgPicture.asset(AppAssets.iconLembur, width: 64, height: 64),
              const SizedBox(height: 22),
              const Text(
                'Apakah Anda lembur?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _OvertimeButton(
                      label: 'Ya',
                      isPrimary: false,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _OvertimeButton(
                      label: 'Tidak',
                      isPrimary: true,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OvertimeButton extends StatelessWidget {
  const _OvertimeButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFD33B32)
              : const Color(0xFFFFE3E3),
          foregroundColor: isPrimary ? Colors.white : AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isPrimary
                  ? const Color(0xFFD33B32)
                  : const Color(0xFFF0B8B8),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
