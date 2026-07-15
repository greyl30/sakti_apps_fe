import 'package:flutter/material.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../history/presentation/widgets/history_filter_chip.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/emergency_history_model.dart';
import '../widgets/emergency_history_card.dart';

class EmergencyHistoryPage extends StatefulWidget {
  const EmergencyHistoryPage({super.key});

  @override
  State<EmergencyHistoryPage> createState() => _EmergencyHistoryPageState();
}

class _EmergencyHistoryPageState extends State<EmergencyHistoryPage> {
  EmergencyHistoryType? _selectedType;

  @override
  Widget build(BuildContext context) {
    // TODO(Backend):
    // Ambil data riwayat dispensasi dan cuti darurat dari API.
    final histories = dummyEmergencyHistories;
    final filteredHistories = _selectedType == null
        ? histories
        : histories
              .where((history) => history.requestType == _selectedType)
              .toList();

    // TODO(UI):
    // Tambahkan Empty State ketika riwayat darurat kosong.
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top AppBar halaman riwayat darurat.
            const LeaveTopBar(
              title: 'Riwayat Darurat',
              subtitle: 'Riwayat aktivitas dispensasi dan cuti darurat',
              fallbackRoute: RouteName.emergency,
            ),
            const SizedBox(height: 22),
            // Filter jenis pengajuan, rata kiri sesuai desain.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HistoryFilterChip(
                    label: 'Semua',
                    isSelected: _selectedType == null,
                    onTap: () => setState(() => _selectedType = null),
                  ),
                  const SizedBox(width: 9),
                  HistoryFilterChip(
                    label: 'Dispensasi',
                    isSelected:
                        _selectedType == EmergencyHistoryType.dispensation,
                    onTap: () => setState(
                      () => _selectedType = EmergencyHistoryType.dispensation,
                    ),
                  ),
                  const SizedBox(width: 9),
                  HistoryFilterChip(
                    label: 'Cuti Darurat',
                    isSelected:
                        _selectedType == EmergencyHistoryType.emergencyLeave,
                    onTap: () => setState(
                      () => _selectedType = EmergencyHistoryType.emergencyLeave,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                itemCount: filteredHistories.length,
                itemBuilder: (context, index) {
                  final history = filteredHistories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: EmergencyHistoryCard(history: history),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
