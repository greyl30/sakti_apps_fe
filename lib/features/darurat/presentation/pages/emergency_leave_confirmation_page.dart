import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../leave/presentation/models/leave_request_status.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';
import '../../../leave/presentation/widgets/leave_status_widgets.dart';
import '../../../leave/presentation/widgets/leave_success_widgets.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/emergency_leave_data.dart';

class EmergencyLeaveConfirmationPage extends StatelessWidget {
  const EmergencyLeaveConfirmationPage({super.key, required this.data});

  final EmergencyLeaveData data;

  void _showSuccessDialog(BuildContext context) {
    final statusData = data.toStatusData();

    // Popup berhasil kirim pengajuan, sementara tanpa request backend.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LeaveConfirmationDialog(
        title: 'Pengajuan Cuti Darurat Terkirim',
        description:
            'Pengajuan Anda telah berhasil dikirim dan sedang menunggu proses persetujuan.',
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(
            RouteName.leaveStatus,
            extra: LeaveStatusRouteData(
              data: statusData,
              fallbackRoute: RouteName.emergency,
              bottomNavigationIndex: 3,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman konfirmasi cuti darurat
            const LeaveTopBar(
              title: 'Konfirmasi Pengajuan',
              subtitle: 'Konfirmasi pengajuan cuti darurat Anda',
              fallbackRoute: RouteName.emergency,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card ringkasan pengajuan cuti darurat.
                  _EmergencyLeaveSummaryCard(data: data),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.secondaryBlue,
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Setelah diklik, pengajuan akan dikirim ke atasan Anda untuk mendapat persetujuan. Anda akan menerima notifikasi setelah ada keputusan.',
                            style: TextStyle(
                              color: Color(0xFF5F6972),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol kirim pengajuan cuti darurat.
                  LeavePrimaryButton(
                    label: 'Kirim Pengajuan',
                    onPressed: () => _showSuccessDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }
}

class _EmergencyLeaveSummaryCard extends StatelessWidget {
  const _EmergencyLeaveSummaryCard({required this.data});

  final EmergencyLeaveData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RINGKASAN PENGAJUAN CUTI DARURAT',
            style: TextStyle(
              color: Color(0xFF8A8F98),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 18),
          const LeaveInfoRow(
            icon: AppAssets.iconSisa,
            label: 'Jenis Pengajuan',
            value: 'Cuti Darurat',
          ),
          LeaveInfoRow(
            icon: AppAssets.iconAlasan,
            label: 'Alasan',
            value: data.reason,
          ),
          LeaveInfoRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Mulai',
            value: _formatLongDate(data.startDate),
          ),
          LeaveInfoRow(
            icon: AppAssets.iconCalendar,
            label: 'Tanggal Selesai',
            value: _formatLongDate(data.endDate),
          ),
          LeaveInfoRow(
            icon: AppAssets.iconDurasi,
            label: 'Jumlah Hari',
            value: '${data.totalDays} hari kerja',
          ),
        ],
      ),
    );
  }
}

String _formatLongDate(DateTime date) {
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
