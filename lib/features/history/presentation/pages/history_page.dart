import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/attendance_history_model.dart';
import '../providers/attendance_history_provider.dart';
import '../widgets/history_attendance_card.dart';
import '../widgets/history_filter_chip.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  AttendanceHistoryStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(attendanceHistoriesProvider));
  }

  @override
  Widget build(BuildContext context) {
    final historiesAsync = ref.watch(attendanceHistoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman riwayat presensi.
            const LeaveTopBar(
              title: 'Riwayat Presensi',
              subtitle: 'Riwayat seluruh aktivitas presensi Anda',
              fallbackRoute: RouteName.home,
            ),
            const SizedBox(height: 22),
            // Filter status riwayat.
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HistoryFilterChip(
                      label: 'Semua',
                      isSelected: _selectedStatus == null,
                      onTap: () => setState(() => _selectedStatus = null),
                    ),
                    const SizedBox(width: 9),
                    HistoryFilterChip(
                      label: 'Tepat Waktu',
                      isSelected:
                          _selectedStatus == AttendanceHistoryStatus.onTime,
                      onTap: () => setState(
                        () => _selectedStatus = AttendanceHistoryStatus.onTime,
                      ),
                    ),
                    const SizedBox(width: 9),
                    HistoryFilterChip(
                      label: 'Terlambat',
                      isSelected:
                          _selectedStatus == AttendanceHistoryStatus.late,
                      onTap: () => setState(
                        () => _selectedStatus = AttendanceHistoryStatus.late,
                      ),
                    ),
                    const SizedBox(width: 9),
                    HistoryFilterChip(
                      label: 'Lembur',
                      isSelected:
                          _selectedStatus == AttendanceHistoryStatus.overtime,
                      onTap: () => setState(
                        () =>
                            _selectedStatus = AttendanceHistoryStatus.overtime,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: historiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
                error: (error, stackTrace) =>
                    _HistoryMessage(message: error.toString()),
                data: (histories) {
                  debugPrint(
                    '[AttendanceHistory] history page received count: '
                    '${histories.length}',
                  );
                  final activities = histories
                      .expand(attendanceHistoryActivities)
                      .where(
                        (activity) =>
                            _selectedStatus == null ||
                            activity.status == _selectedStatus,
                      )
                      .toList();

                  if (activities.isEmpty) {
                    return const _HistoryMessage(
                      message: 'Belum ada riwayat presensi',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryRed,
                    onRefresh: () =>
                        ref.refresh(attendanceHistoriesProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: HistoryAttendanceCard(activity: activity),
                        );
                      },
                    ),
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

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
