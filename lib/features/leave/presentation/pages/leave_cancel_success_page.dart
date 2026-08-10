import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
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
    final resolvedCancelReason = _cleanCancelReason(cancelReason);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 45, 24, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => _goBack(context),
                customBorder: const CircleBorder(),
                child: SvgPicture.asset(AppAssets.back2, width: 41, height: 41),
              ),
            ),
            const SizedBox(height: 20),
            const LeaveSuccessHeader(
              title: 'Pembatalan Berhasil!',
              description: 'Kuota cuti yang sebelumnya akan dikembalikan',
            ),
            const SizedBox(height: 28),
            LeaveSummaryCard(data: data, cancelReason: resolvedCancelReason),
            const SizedBox(height: 28),
            LeavePrimaryButton(
              label: 'Kembali ke Beranda',
              onPressed: () => context.go(RouteName.home),
            ),
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

  String? _cleanCancelReason(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.toLowerCase() == 'dibatalkan oleh karyawan') return null;

    return trimmed;
  }
}
