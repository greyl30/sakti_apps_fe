import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/leave_request_status.dart';
import '../providers/leave_submit_provider.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_success_widgets.dart';

class LeaveSuccessPage extends ConsumerWidget {
  const LeaveSuccessPage({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDispensation = data.type.trim().toLowerCase() == 'dispensasi';
    final isRejected = data.status == LeaveApprovalStatus.rejected;
    final leaveId = data.id;
    final isDownloading =
        leaveId != null &&
        ref.watch(leaveLetterDownloadProvider).isProcessing(leaveId);
    final canCancel =
        !isDispensation &&
        data.status == LeaveApprovalStatus.approved &&
        (data.id?.isNotEmpty ?? false);

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
                onTap: () => _goBack(context),
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
              showRemainingLeave: false,
            ),
            const SizedBox(height: 28),
            if (isRejected)
              LeaveSecondaryButton(
                label: 'Kembali ke Cuti',
                onPressed: () => context.go(RouteName.leave),
              )
            else ...[
              LeavePrimaryButton(
                label: isDownloading
                    ? 'Mengunduh Surat...'
                    : isDispensation
                    ? 'Unduh Surat Dispensasi'
                    : 'Unduh Surat Cuti',
                onPressed: isDownloading
                    ? null
                    : () => _downloadLetter(context, ref, data),
              ),
              const SizedBox(height: 16),
              if (isDispensation)
                LeaveSecondaryButton(
                  label: 'Kembali ke Beranda',
                  onPressed: () => context.go(RouteName.home),
                )
              else if (canCancel)
                LeaveSecondaryButton(
                  label: 'Batalkan Cuti',
                  onPressed: () =>
                      context.push(RouteName.leaveCancel, extra: data),
                )
              else
                LeaveSecondaryButton(
                  label: 'Kembali ke Cuti',
                  onPressed: () => context.go(RouteName.leave),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteName.leave);
  }

  Future<void> _downloadLetter(
    BuildContext context,
    WidgetRef ref,
    LeaveRequestStatusData data,
  ) async {
    final leaveId = data.id;
    if (leaveId == null || leaveId.isEmpty) {
      _showSnackBar(context, 'Data pengajuan cuti tidak lengkap.');
      return;
    }

    final success = await ref
        .read(leaveLetterDownloadProvider.notifier)
        .download(leaveId);

    if (!context.mounted) return;

    if (success) {
      _showSnackBar(context, 'Surat berhasil diunduh');
      return;
    }

    final message = ref.read(leaveLetterDownloadProvider).errorMessage;
    _showSnackBar(context, message ?? 'Gagal mengunduh surat.');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
