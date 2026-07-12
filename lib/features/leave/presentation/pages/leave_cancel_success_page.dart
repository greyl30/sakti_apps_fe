import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/leave_request_status.dart';
import '../widgets/leave_list_item.dart';
import '../widgets/leave_success_widgets.dart';

class LeaveCancelSuccessPage extends StatelessWidget {
  const LeaveCancelSuccessPage({
    super.key,
    required this.data,
    required this.cancelReason,
  });

  final LeaveRequestStatusData data;
  final String cancelReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 110, 24, 28),
          children: [
            // Halaman sukses pembatalan tanpa Top AppBar.
            const LeaveSuccessHeader(
              title: 'Pembatalan Berhasil!',
              description: 'Kuota cuti yang sebelumnya akan dikembalikan',
            ),
            const SizedBox(height: 28),
            LeaveSummaryCard(data: data, cancelReason: cancelReason),
            const SizedBox(height: 28),
            LeavePrimaryButton(
              label: 'Kembali ke Beranda',
              onPressed: () => context.go(RouteName.leave),
            ),
          ],
        ),
      ),
    );
  }
}
