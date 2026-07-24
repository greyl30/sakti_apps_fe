import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/leave_request_status.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_success_widgets.dart';

class LeaveSuccessPage extends StatelessWidget {
  const LeaveSuccessPage({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  Widget build(BuildContext context) {
    final isDispensation = data.type.trim().toLowerCase() == 'dispensasi';
    final isRejected = data.status == LeaveApprovalStatus.rejected;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 54, 24, 28),
          children: [
            // Tombol kembali tanpa Top AppBar.
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.go(
                  isDispensation || isRejected
                      ? RouteName.leave
                      : RouteName.leaveStatus,
                  extra: isDispensation || isRejected ? null : data,
                ),
                customBorder: const CircleBorder(),
                child: SvgPicture.asset(AppAssets.back2, width: 40, height: 40),
              ),
            ),
            const SizedBox(height: 20),
            LeaveSuccessHeader(
              title: isRejected
                  ? 'Pengajuan Cuti Ditolak'
                  : isDispensation
                  ? 'Pengajuan Dispensasi Berhasil!'
                  : 'Pengajuan Cuti Berhasil!',
              description: isRejected
                  ? 'Pengajuan cuti Anda tidak disetujui.'
                  : isDispensation
                  ? 'Dispensasi Anda telah tercatat dalam sistem.'
                  : 'Cuti Anda telah disetujui dan tercatat dalam sistem',
              badge: isRejected ? 'DITOLAK' : 'DISETUJUI',
              icon: isRejected ? AppAssets.iconNo : AppAssets.iconCheck,
            ),
            const SizedBox(height: 28),
            // Ringkasan data pengajuan cuti.
            LeaveSummaryCard(
              data: data,
              cancelReason: isRejected ? data.resultReason : null,
              cancelReasonLabel: 'Alasan penolakan',
              showRemainingLeave: !isDispensation,
            ),
            const SizedBox(height: 28),
            if (isRejected)
              LeaveSecondaryButton(
                label: 'Kembali ke Cuti',
                onPressed: () => context.go(RouteName.leave),
              )
            else ...[
              LeavePrimaryButton(
                label: 'Unduh Surat',
                onPressed: () {
                  // Backend nantinya akan mengirim file PDF surat cuti.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Download surat cuti akan dihubungkan dengan backend.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (isDispensation)
                LeaveSecondaryButton(
                  label: 'Kembali ke Beranda',
                  onPressed: () => context.go(RouteName.home),
                )
              else
                LeaveSecondaryButton(
                  label: 'Batalkan Cuti',
                  onPressed: () =>
                      context.push(RouteName.leaveCancel, extra: data),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
