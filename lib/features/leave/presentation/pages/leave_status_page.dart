import 'package:flutter/material.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../models/leave_request_status.dart';
import '../widgets/leave_status_widgets.dart';
import '../widgets/leave_top_bar.dart';

class LeaveStatusPage extends StatelessWidget {
  const LeaveStatusPage({
    super.key,
    required this.data,
    this.fallbackRoute = RouteName.leave,
    this.bottomNavigationIndex = 2,
  });

  final LeaveRequestStatusData data;
  final String fallbackRoute;
  final int bottomNavigationIndex;

  @override
  Widget build(BuildContext context) {
    final subtitle = _statusSubtitle(data);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar status pengajuan
            LeaveTopBar(
              title: 'Status Pengajuan',
              subtitle: subtitle,
              fallbackRoute: fallbackRoute,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card status besar
                  LeaveStatusCard(data: data),
                  const SizedBox(height: 24),
                  // Card detail pengajuan
                  LeaveDetailCard(data: data),
                  const SizedBox(height: 24),
                  // Card alur persetujuan
                  LeaveApprovalTimelineCard(data: data),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: bottomNavigationIndex,
      ),
    );
  }
}

String _statusSubtitle(LeaveRequestStatusData data) {
  return switch (data.status) {
    LeaveApprovalStatus.waitingSupervisor => 'Menunggu persetujuan atasan',
    LeaveApprovalStatus.waitingHRD => 'Menunggu finalisasi HRD',
    LeaveApprovalStatus.approved => 'Pengajuan selesai/disetujui',
    LeaveApprovalStatus.rejected => 'Pengajuan ditolak',
    LeaveApprovalStatus.canceled => 'Pengajuan dibatalkan',
  };
}
