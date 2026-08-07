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
    final isBeforeLeaveStart = _isBeforeLeaveStart(DateTime.now(), data);
    final canSubmitCancellation = canCancel && isBeforeLeaveStart;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, isRejected ? 40 : 54, 24, 28),
          children: [
            // Tombol kembali tanpa Top AppBar.
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () =>
                    isRejected ? context.go(RouteName.leave) : _goBack(context),
                customBorder: const CircleBorder(),
                child: SvgPicture.asset(AppAssets.back2, width: 41, height: 41),
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
              cancelReasonLabel: 'Alasan Ditolak',
              showRemainingLeave: false,
            ),
            const SizedBox(height: 28),
            if (isRejected)
              LeavePrimaryButton(
                label: 'Kembali ke Beranda',
                onPressed: () => context.go(RouteName.home),
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
                Column(
                  children: [
                    LeaveSecondaryButton(
                      label: 'Batalkan Cuti',
                      onPressed: canSubmitCancellation
                          ? () =>
                                context.push(RouteName.leaveCancel, extra: data)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pembatalan hanya dapat dilakukan sebelum hari H.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8A8F98),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
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

  bool _isBeforeLeaveStart(DateTime now, LeaveRequestStatusData data) {
    final today = DateTime(now.year, now.month, now.day);
    final leaveStart = DateTime(
      data.startDate.year,
      data.startDate.month,
      data.startDate.day,
    );

    return today.isBefore(leaveStart);
  }
}
