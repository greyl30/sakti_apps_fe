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
    final timeValue = _resolveRecordedTime(response, flowType);
    final dateValue = _formatAttendanceDate(response?.attendanceDate);
    final totalWorkTime = _formatWorkDuration(response);
    final isInsideRadius = response != null && !response!.isOutsideRadius;
    final distanceText = _formatAttendanceDistance(response?.distanceMeter);
    final hasWarning =
        response != null && (response!.isLate || response!.isOutsideRadius);

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
                            _SuccessInfoRow(
                              icon: AppAssets.iconCalendar,
                              label: 'Tanggal',
                              value: dateValue,
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
                                value: totalWorkTime ?? '-',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (hasWarning) ...[
                        _AttendanceWarningCard(response: response!),
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

String _resolveRecordedTime(
  AttendanceSubmitResponse? response,
  AttendanceFlowType flowType,
) {
  final rawTime = flowType.isCheckIn
      ? response?.clockInTime
      : response?.clockOutTime ?? response?.clockInTime;

  return _formatAttendanceTime(rawTime) ?? '-';
}

String _formatAttendanceDate(String? value) {
  final parsedDate = _parseAttendanceDate(value);
  if (parsedDate == null) return '-';

  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${days[parsedDate.weekday - 1]}, ${parsedDate.day} '
      '${months[parsedDate.month - 1]} ${parsedDate.year}';
}

String? _formatAttendanceTime(String? value) {
  final parsedTime = _parseAttendanceTime(value);
  if (parsedTime == null) return null;

  final hour = parsedTime.hour.toString().padLeft(2, '0');
  final minute = parsedTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}

String? _formatWorkDuration(AttendanceSubmitResponse? response) {
  final attendanceDate = _parseAttendanceDate(response?.attendanceDate);
  final clockIn = _parseAttendanceTime(response?.clockInTime);
  final clockOut = _parseAttendanceTime(response?.clockOutTime);
  if (attendanceDate == null || clockIn == null || clockOut == null) {
    return null;
  }

  final start = DateTime(
    attendanceDate.year,
    attendanceDate.month,
    attendanceDate.day,
    clockIn.hour,
    clockIn.minute,
    clockIn.second,
  );
  var end = DateTime(
    attendanceDate.year,
    attendanceDate.month,
    attendanceDate.day,
    clockOut.hour,
    clockOut.minute,
    clockOut.second,
  );
  if (end.isBefore(start)) {
    end = end.add(const Duration(days: 1));
  }

  final duration = end.difference(start);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours <= 0) return '$minutes menit';
  if (minutes == 0) return '$hours jam';
  return '$hours jam $minutes menit';
}

DateTime? _parseAttendanceDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

DateTime? _parseAttendanceTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;

  final parsedDateTime = DateTime.tryParse(value);
  if (parsedDateTime != null) return parsedDateTime;

  final parts = value.split(':');
  final hour = int.tryParse(parts.elementAtOrNull(0) ?? '');
  final minute = int.tryParse(parts.elementAtOrNull(1) ?? '');
  final second = int.tryParse(parts.elementAtOrNull(2) ?? '') ?? 0;
  if (hour == null || minute == null) return null;

  return DateTime(0, 1, 1, hour, minute, second);
}

String? _formatAttendanceDistance(num? value) {
  if (value == null) return null;
  if (value >= 1000) {
    final kilometers = value / 1000;
    return '${kilometers.toStringAsFixed(kilometers >= 10 ? 0 : 1)} km';
  }

  return '${value.round()} meter';
}

class _AttendanceWarningCard extends StatelessWidget {
  const _AttendanceWarningCard({required this.response});

  final AttendanceSubmitResponse response;

  @override
  Widget build(BuildContext context) {
    final warningLabels = [
      if (response.isLate) 'Terlambat',
      if (response.isOutsideRadius) 'Di luar radius kantor',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD29B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < warningLabels.length; index++) ...[
            _WarningStatusRow(label: warningLabels[index]),
            if (index != warningLabels.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _WarningStatusRow extends StatelessWidget {
  const _WarningStatusRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 7,
          height: 7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFD17A00),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'Status: $label',
            style: const TextStyle(
              color: Color(0xFF7A4A12),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
      ],
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
