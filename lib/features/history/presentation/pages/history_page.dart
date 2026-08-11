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
  Widget build(BuildContext context) {
    final histories = ref.watch(paginatedAttendanceHistoriesProvider);

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
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: () => ref
                    .read(paginatedAttendanceHistoriesProvider.notifier)
                    .refresh(),
                child: _buildHistoryList(histories),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(PaginatedAttendanceHistoriesState histories) {
    if (histories.isLoading && histories.items.isEmpty) {
      return const _HistoryMessage(message: 'Memuat riwayat presensi...');
    }

    if (histories.errorMessage != null && histories.items.isEmpty) {
      return _HistoryMessage(message: histories.errorMessage!);
    }

    debugPrint(
      '[AttendanceHistory] history page received count: '
      '${histories.items.length}',
    );
    final activities =
        _uniqueActivities(
          histories.items.expand(attendanceHistoryActivities),
        ).where((activity) {
          return _selectedStatus == null || activity.status == _selectedStatus;
        }).toList();

    if (activities.isEmpty) {
      return const _HistoryMessage(message: 'Belum ada riwayat presensi');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      itemCount: activities.length + (histories.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == activities.length) {
          return _LoadMoreAttendanceAction(
            isLoading: histories.isLoadingMore,
            onTap: () => ref
                .read(paginatedAttendanceHistoriesProvider.notifier)
                .loadMore(),
          );
        }

        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: HistoryAttendanceCard(activity: activity),
        );
      },
    );
  }

  List<AttendanceHistoryActivity> _uniqueActivities(
    Iterable<AttendanceHistoryActivity> activities,
  ) {
    final seenKeys = <String>{};
    final uniqueActivities = <AttendanceHistoryActivity>[];

    for (final activity in activities) {
      if (!seenKeys.add(activity.id)) continue;

      uniqueActivities.add(activity);
    }

    return uniqueActivities;
  }
}

class _LoadMoreAttendanceAction extends StatelessWidget {
  const _LoadMoreAttendanceAction({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Center(
        child: TextButton.icon(
          onPressed: isLoading ? null : onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondaryBlue,
                  ),
                )
              : const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          label: Text(
            isLoading ? 'Memuat...' : 'Muat lebih banyak',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
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
