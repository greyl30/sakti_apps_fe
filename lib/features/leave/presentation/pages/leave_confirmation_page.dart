import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../home/presentation/providers/hrd_leave_finalization_provider.dart';
import '../models/leave_form_data.dart';
import '../models/leave_request_status.dart';
import '../providers/leave_submit_provider.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_top_bar.dart';

class LeaveConfirmationPage extends ConsumerWidget {
  const LeaveConfirmationPage({super.key, required this.data});

  final LeaveFormData data;

  Future<void> _submitLeave(BuildContext context, WidgetRef ref) async {
    final response = await ref.read(leaveSubmitProvider.notifier).submit(data);
    if (!context.mounted) return;

    if (response == null) {
      final message = ref.read(leaveSubmitProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Gagal mengirim pengajuan cuti.'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    ref.invalidate(leaveStatusesProvider);
    ref.invalidate(activeLeaveRequestsProvider);
    ref.invalidate(leaveHistoryRequestsProvider);
    ref.invalidate(hrdPendingLeaveFinalizationsProvider);
    _showSuccessDialog(context, response.toStatusData());
  }

  void _showSuccessDialog(
    BuildContext context,
    LeaveRequestStatusData statusData,
  ) {
    final isDispensation = _isDispensation(data.type);

    // Popup berhasil mengirim pengajuan cuti.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8FD),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppAssets.iconCheck,
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    AppColors.secondaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isDispensation
                    ? 'Pengajuan Dispensasi Berhasil'
                    : 'Pengajuan Cuti Terkirim',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isDispensation
                    ? 'Dispensasi telah tercatat dalam sistem. Notifikasi telah dikirim kepada Atasan dan HRD.'
                    : 'Pengajuan cuti Anda telah berhasil dikirim dan sedang menunggu proses persetujuan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go(
                      isDispensation
                          ? RouteName.leaveSuccess
                          : RouteName.leaveStatus,
                      extra: statusData,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD33B32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDispensation = _isDispensation(data.type);
    final submitState = ref.watch(leaveSubmitProvider);
    final balance = ref.watch(leaveBalanceProvider);
    final balanceData = balance.valueOrNull;
    final isBalanceLoading = balance.isLoading && balanceData == null;
    final remainingAfterRequest = balanceData == null
        ? null
        : _remainingAfterRequest(balanceData.remainingLeave, data.totalDays);
    final availableRequestQuota = balanceData?.availableRequestQuota;
    final isQuotaExceeded =
        availableRequestQuota != null && data.totalDays > availableRequestQuota;
    final canSubmit =
        !submitState.isLoading &&
        availableRequestQuota != null &&
        !isQuotaExceeded;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman konfirmasi pengajuan
            LeaveTopBar(
              title: isDispensation
                  ? 'Konfirmasi Pengajuan Dispensasi'
                  : 'Konfirmasi Pengajuan',
              subtitle: isDispensation
                  ? 'Konfirmasi pengajuan dispensasi Anda'
                  : 'Konfirmasi pengajuan cuti Anda',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card ringkasan pengajuan cuti
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                        Text(
                          isDispensation
                              ? 'RINGKASAN PENGAJUAN DISPENSASI'
                              : 'RINGKASAN PENGAJUAN CUTI',
                          style: const TextStyle(
                            color: Color(0xFF8A8F98),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _SummaryRow(
                          icon: AppAssets.iconCalendar,
                          label: 'Tanggal Mulai',
                          value: _formatLongDate(data.startDate),
                        ),
                        const SizedBox(height: 14),
                        _SummaryRow(
                          icon: AppAssets.iconCalendar,
                          label: 'Tanggal Selesai',
                          value: _formatLongDate(data.endDate),
                        ),
                        const SizedBox(height: 14),
                        _SummaryRow(
                          icon: AppAssets.iconDurasi,
                          label: 'Durasi',
                          value: '${data.totalDays} hari kerja',
                        ),
                        const SizedBox(height: 14),
                        if (!isDispensation) ...[
                          _SummaryRow(
                            icon: AppAssets.iconSisa,
                            label: 'Sisa Cuti',
                            value: remainingAfterRequest == null
                                ? isBalanceLoading
                                      ? '...'
                                      : '-'
                                : '$remainingAfterRequest hari',
                          ),
                          const SizedBox(height: 14),
                        ],
                        _SummaryRow(
                          icon: AppAssets.iconAlasan,
                          label: 'Alasan',
                          value: data.type,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.iconInfo,
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isDispensation
                                ? 'Setelah diklik, dispensasi akan langsung tercatat dalam sistem serta notifikasi akan dikirim kepada Atasan dan HRD.'
                                : 'Setelah diklik, pengajuan akan dikirim ke atasan Anda untuk mendapat persetujuan.',
                            style: const TextStyle(
                              color: Color(0xFF5F6972),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isQuotaExceeded) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Jumlah hari cuti melebihi kuota pengajuan yang tersedia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Tombol ajukan cuti
                  LeavePrimaryButton(
                    label: submitState.isLoading
                        ? 'Mengirim...'
                        : isDispensation
                        ? 'Ajukan Dispensasi'
                        : 'Ajukan Cuti',
                    onPressed: canSubmit
                        ? () => _submitLeave(context, ref)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
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

  bool _isDispensation(String type) {
    return type.trim().toLowerCase() == 'dispensasi';
  }
}

int _remainingAfterRequest(int remainingLeave, int requestDays) {
  final result = remainingLeave - requestDays;
  return result < 0 ? 0 : result;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.secondaryBlue,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
