import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../data/models/attendance_submit_response.dart';
import '../models/attendance_flow_type.dart';
import '../widgets/attendance_primary_button.dart';

class CheckInSuccessPage extends StatelessWidget {
  const CheckInSuccessPage({
    super.key,
    required this.flowType,
    this.isOvertime = false,
    this.response,
  });

  final AttendanceFlowType flowType;
  final bool isOvertime;
  final AttendanceSubmitResponse? response;

  @override
  Widget build(BuildContext context) {
    final isAttendanceOvertime = response?.isOvertime ?? isOvertime;
    final timeValue = isAttendanceOvertime ? '20:30 WIB' : flowType.successTime;
    final totalWorkTime = isAttendanceOvertime
        ? '12 jam 30 menit'
        : '9 jam 5 menit';
    final isInsideRadius = response != null && !response!.isOutsideRadius;
    final distanceText = _formatAttendanceDistance(response?.distanceMeter);

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
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFDDD9),
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
                      Text(
                        flowType.successTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flowType.successRecordedLabel,
                              style: const TextStyle(
                                color: Color(0xFF8A8F98),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              timeValue,
                              style: const TextStyle(
                                color: Color(0xFF4C9CB2),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const _SuccessInfoRow(
                              icon: AppAssets.iconCalendar,
                              label: 'Tanggal',
                              value: 'Senin, 23 Juni 2025',
                            ),
                            if (isInsideRadius) ...[
                              const SizedBox(height: 16),
                              const _SuccessInfoRow(
                                icon: AppAssets.iconLokasi,
                                label: 'Status',
                                value: 'Di dalam radius kantor',
                              ),
                              if (distanceText != null) ...[
                                const SizedBox(height: 16),
                                _SuccessInfoRow(
                                  icon: AppAssets.iconLokasi,
                                  label: 'Jarak',
                                  value: distanceText,
                                ),
                              ],
                            ],
                            if (!flowType.isCheckIn) ...[
                              const SizedBox(height: 16),
                              _SuccessInfoRow(
                                icon: AppAssets.iconDurasi,
                                label: 'Total Waktu',
                                value: totalWorkTime,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (response != null && response!.isOutsideRadius) ...[
                        _LocationValidationCard(response: response!),
                        const SizedBox(height: 30),
                      ],
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

String? _formatAttendanceDistance(num? value) {
  if (value == null) return null;
  if (value >= 1000) {
    final kilometers = value / 1000;
    return '${kilometers.toStringAsFixed(kilometers >= 10 ? 0 : 1)} km';
  }

  return '${value.round()} meter';
}

class _LocationValidationCard extends StatelessWidget {
  const _LocationValidationCard({required this.response});

  final AttendanceSubmitResponse response;

  @override
  Widget build(BuildContext context) {
    final isOutsideRadius = response.isOutsideRadius;
    final distanceText = _formatDistance(response.distanceMeter);
    final radiusText = _formatDistance(response.officeRadius);
    final statusText = _formatLocationStatus(response.locationStatus);

    final backgroundColor = isOutsideRadius
        ? const Color(0xFFFFF4E5)
        : const Color(0xFFEAF8FD);
    final borderColor = isOutsideRadius
        ? const Color(0xFFFFD29B)
        : const Color(0xFFC6E6F0);
    final titleColor = isOutsideRadius
        ? const Color(0xFFD17A00)
        : const Color(0xFF4C9CB2);
    final bodyColor = isOutsideRadius
        ? const Color(0xFF7A4A12)
        : const Color(0xFF5F6972);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOutsideRadius
                ? 'Lokasi di luar radius kantor'
                : 'Lokasi di dalam radius kantor',
            style: TextStyle(
              color: titleColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            isOutsideRadius
                ? 'Presensi tetap tercatat. Sistem mendeteksi Anda berada di luar radius kantor.'
                : 'Presensi tercatat dari lokasi yang berada dalam radius kantor.',
            style: TextStyle(
              color: bodyColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          if (statusText != null ||
              distanceText != null ||
              radiusText != null) ...[
            const SizedBox(height: 10),
            if (statusText != null) ...[
              _LocationInfoText(
                label: 'Status lokasi',
                value: statusText,
                color: titleColor,
              ),
              const SizedBox(height: 6),
            ],
            if (distanceText != null)
              _LocationInfoText(
                label: 'Jarak dari kantor',
                value: distanceText,
                color: titleColor,
              ),
            if (radiusText != null) ...[
              const SizedBox(height: 6),
              _LocationInfoText(
                label: 'Radius kantor',
                value: radiusText,
                color: titleColor,
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String? _formatDistance(num? value) {
    return _formatAttendanceDistance(value);
  }

  static String? _formatLocationStatus(String? value) {
    if (value == null) return null;
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _LocationInfoText extends StatelessWidget {
  const _LocationInfoText({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
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
