import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../models/leave_request_status.dart';
import '../providers/leave_submit_provider.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_success_widgets.dart';
import '../widgets/leave_top_bar.dart';

class LeaveCancelPage extends ConsumerStatefulWidget {
  const LeaveCancelPage({super.key, required this.data});

  final LeaveRequestStatusData data;

  @override
  ConsumerState<LeaveCancelPage> createState() => _LeaveCancelPageState();
}

class _LeaveCancelPageState extends ConsumerState<LeaveCancelPage> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitCancellation() async {
    final leaveId = widget.data.id;
    final reason = _resolvedReason;

    if (leaveId == null || leaveId.isEmpty) {
      _showError('Data pengajuan cuti tidak lengkap.');
      return;
    }

    final success = await ref
        .read(leaveCancelProvider.notifier)
        .cancel(leaveId: leaveId, reason: reason);

    if (!mounted) return;

    if (!success) {
      final message = ref.read(leaveCancelProvider).errorMessage;
      _showError(message ?? 'Gagal membatalkan cuti.');
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LeaveConfirmationDialog(
        title: 'Pembatalan Cuti Terkirim',
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(
            RouteName.leaveCancelSuccess,
            extra: {'data': widget.data, 'reason': reason},
          );
        },
      ),
    );
  }

  String get _resolvedReason {
    final reason = _reasonController.text.trim();
    if (reason.isNotEmpty) return reason;
    return 'Ada keperluan mendadak lainnya';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cancelState = ref.watch(leaveCancelProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman pembatalan.
            const LeaveTopBar(
              title: 'Batalkan Cuti',
              subtitle: 'Tindakan ini akan diberitahukan ke atasan',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.secondaryBlue,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Konfirmasi Pembatalan\nPembatalan akan dikirimkan ke atasan. Kuota cuti yang terpakai akan dikembalikan.',
                            style: TextStyle(
                              color: Color(0xFF5F6972),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Card informasi pengajuan.
                  LeaveSummaryCard(data: widget.data),
                  const SizedBox(height: 24),
                  const Text(
                    'Alasan Pembatalan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    minLines: 3,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Tambahkan keterangan...',
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
                        borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol kirim pembatalan.
                  LeavePrimaryButton(
                    label: cancelState.isLoading
                        ? 'Mengirim Pembatalan...'
                        : 'Kirim Pembatalan',
                    onPressed: cancelState.isLoading
                        ? null
                        : _submitCancellation,
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
}
