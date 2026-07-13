import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_list_item.dart';
import '../../../leave/presentation/widgets/leave_success_widgets.dart';
import '../models/emergency_dispensation_data.dart';
import '../widgets/emergency_summary_card.dart';

class EmergencyDispensationSuccessPage extends StatelessWidget {
  const EmergencyDispensationSuccessPage({super.key, required this.data});

  final EmergencyDispensationData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 42, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 70,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header sukses dispensasi
                    const LeaveSuccessHeader(
                      title: 'Perizinan Dispensasi Berhasil!',
                      description:
                          'Dispensasi ini tidak akan mengurangi kuota cuti',
                    ),
                    const SizedBox(height: 28),
                    // Ringkasan data dispensasi
                    EmergencySummaryCard(
                      title: 'RINGKASAN DISPENSASI',
                      startDate: data.startDate,
                      endDate: data.endDate,
                      reason: data.reason,
                    ),
                    const SizedBox(height: 26),
                    // Tombol kembali ke dashboard Darurat
                    LeavePrimaryButton(
                      label: 'Kembali ke Beranda',
                      onPressed: () => context.go(RouteName.emergency),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
