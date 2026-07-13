import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';
import '../../../leave/presentation/widgets/leave_success_widgets.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/emergency_dispensation_data.dart';
import '../widgets/emergency_summary_card.dart';

class EmergencyDispensationConfirmationPage extends StatelessWidget {
  const EmergencyDispensationConfirmationPage({super.key, required this.data});

  final EmergencyDispensationData data;

  void _showSuccessDialog(BuildContext context) {
    // Popup berhasil dispensasi, sementara tanpa request backend.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LeaveConfirmationDialog(
        title: 'Berhasil mengajukan dispensasi',
        onOkPressed: () {
          Navigator.of(dialogContext).pop();
          context.go(RouteName.emergencyDispensationSuccess, extra: data);
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
            // Top AppBar halaman konfirmasi dispensasi
            const LeaveTopBar(
              title: 'Konfirmasi Dispensasi',
              subtitle: 'Konfirmasi pengajuan dispensasi Anda',
              fallbackRoute: RouteName.emergency,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  // Card ringkasan pengajuan dispensasi
                  EmergencySummaryCard(
                    title: 'RINGKASAN PENGAJUAN CUTI DARURAT',
                    startDate: data.startDate,
                    endDate: data.endDate,
                    reason: data.reason,
                  ),
                  const SizedBox(height: 24),
                  // Tombol kirim dispensasi
                  LeavePrimaryButton(
                    label: 'Kirimkan Dispensasi',
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
