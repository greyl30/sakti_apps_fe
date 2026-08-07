import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../attendance/data/datasources/attendance_remote_data_source.dart';
import '../../../attendance/data/repositories/attendance_repository.dart';
import '../../../attendance/presentation/models/attendance_ui_state.dart';
import '../../../attendance/presentation/utils/attendance_reminder_guard.dart';
import '../../../attendance/presentation/widgets/attendance_status_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../history/presentation/models/attendance_history_model.dart';
import '../../../history/presentation/providers/attendance_history_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../leave/presentation/providers/leave_submit_provider.dart';
import '../models/home_role.dart';
import '../providers/hrd_leave_finalization_provider.dart';
import '../providers/manager_leave_approval_provider.dart';
import '../widgets/home_attendance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_history_section.dart';
import '../widgets/home_role_section.dart';
import '../widgets/home_reminder_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static final AttendanceRepository _attendanceRepository =
      AttendanceRepository(AttendanceRemoteDataSource(ApiClient.dio));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data profil user login dari auth provider.
    final user = ref.watch(authProvider).user;
    final role = userRoleFromPeran(user?.peran);
    final positionParts = [
      user?.levelJabatan ?? user?.peran,
      user?.divisi ?? user?.unit,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    final histories = ref.watch(attendanceHistoriesProvider);
    final holidays = ref.watch(activeLeaveHolidayDatesProvider);
    final leaveStatuses = ref.watch(leaveStatusesProvider);
    final attendanceState = _attendanceStateFromHistories(
      histories.valueOrNull,
    );
    final isAttendanceUnavailable = isAttendanceReminderSuppressed(
      date: DateTime.now(),
      holidays: holidays.valueOrNull ?? const <DateTime>{},
      leaveRequests: leaveStatuses.valueOrNull ?? const [],
    );
    final isCalendarHoliday = _isCalendarHoliday(
      DateTime.now(),
      holidays.valueOrNull ?? const <DateTime>{},
    );
    final unreadCount = ref.watch(notificationUnreadCountProvider);
    final hasUnreadNotifications = (unreadCount.valueOrNull ?? 0) > 0;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryRed,
          onRefresh: () => _refreshHome(ref, role),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              HomeHeader(
                userName: _displayValue(user?.namaLengkap),
                positionLabel: positionParts.isEmpty
                    ? '-'
                    : positionParts.join(' | '),
                onProfileTap: () => context.push(RouteName.profile),
                onNotificationTap: () => context.push(RouteName.notification),
                hasUnreadNotifications: hasUnreadNotifications,
                photoUrl: user?.fotoUrl,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeAttendanceCard(
                      isHoliday: isAttendanceUnavailable,
                      canCheckIn:
                          !isAttendanceUnavailable &&
                          !attendanceState.hasClockIn,
                      canCheckOut:
                          !isAttendanceUnavailable &&
                          attendanceState.hasClockIn &&
                          !attendanceState.hasClockOut,
                      onCheckInTap: () => _handleCheckInTap(
                        context,
                        isHoliday: isAttendanceUnavailable,
                        hasClockIn: attendanceState.hasClockIn,
                      ),
                      onCheckOutTap: () => _handleCheckOutTap(
                        context,
                        isHoliday: isAttendanceUnavailable,
                        hasClockIn: attendanceState.hasClockIn,
                        hasClockOut: attendanceState.hasClockOut,
                      ),
                    ),
                    const SizedBox(height: 20),
                    HomeReminderSection(
                      isHoliday: isCalendarHoliday,
                      onCheckInReminderTap: () => _handleCheckInTap(
                        context,
                        isHoliday: isAttendanceUnavailable,
                        hasClockIn: attendanceState.hasClockIn,
                      ),
                      onCheckOutReminderTap: () => _handleCheckOutTap(
                        context,
                        isHoliday: isAttendanceUnavailable,
                        hasClockIn: attendanceState.hasClockIn,
                        hasClockOut: attendanceState.hasClockOut,
                      ),
                    ),
                    HomeRoleSection(
                      role: role,
                      onSeeAllTap: () =>
                          context.push(RouteName.managerLeaveApprovals),
                      onItemTap: () =>
                          context.push(RouteName.managerLeaveApprovals),
                    ),
                    const SizedBox(height: 20),
                    HomeHistorySection(
                      onSeeAllTap: () => context.push(RouteName.history),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  void _handleCheckInTap(
    BuildContext context, {
    required bool isHoliday,
    required bool hasClockIn,
  }) {
    if (isHoliday) {
      _showHolidayDialog(context);
      return;
    }

    if (hasClockIn) return;

    context.push(RouteName.checkInVerification);
  }

  void _handleCheckOutTap(
    BuildContext context, {
    required bool isHoliday,
    required bool hasClockIn,
    required bool hasClockOut,
  }) async {
    if (isHoliday) {
      _showHolidayDialog(context);
      return;
    }

    if (!hasClockIn) {
      _showCheckOutUnavailableDialog(context);
      return;
    }

    if (hasClockOut) return;

    final canCheckOut = await _canCheckOutByWorkConfig(context);
    if (!context.mounted) return;
    if (!canCheckOut) return;

    context.push(RouteName.checkOutVerification);
  }

  Future<bool> _canCheckOutByWorkConfig(BuildContext context) async {
    try {
      final config = await _attendanceRepository.getWorkConfig();
      if (!context.mounted) return false;
      final now = DateTime.now();
      if (now.isBefore(config.minimumClockOutDateTime(now))) {
        _showCheckOutUnavailableDialog(context);
        return false;
      }

      return true;
    } catch (_) {
      if (!context.mounted) return false;
      _showCheckOutUnavailableDialog(context);
      return false;
    }
  }

  Future<void> _refreshHome(WidgetRef ref, UserRole role) async {
    ref.invalidate(attendanceHistoriesProvider);
    ref.invalidate(activeLeaveHolidayDatesProvider);
    ref.invalidate(leaveStatusesProvider);
    switch (role) {
      case UserRole.manager:
        ref.invalidate(managerPendingLeaveApprovalsProvider);
      case UserRole.hrd:
        ref.invalidate(hrdPendingLeaveFinalizationsProvider);
      case UserRole.employee:
        break;
    }

    final futures = <Future<void>>[
      ref.read(attendanceHistoriesProvider.future).then((_) {}),
      ref.read(activeLeaveHolidayDatesProvider.future).then((_) {}),
      ref.read(leaveStatusesProvider.future).then((_) {}),
      ref.read(notificationsProvider.notifier).refresh(),
      ref.read(notificationUnreadCountProvider.notifier).refresh(),
      if (role == UserRole.manager)
        ref.read(managerPendingLeaveApprovalsProvider.future).then((_) {}),
      if (role == UserRole.hrd)
        ref.read(hrdPendingLeaveFinalizationsProvider.future).then((_) {}),
    ];

    await Future.wait(
      futures.map((future) async {
        try {
          await future;
        } catch (_) {}
      }),
    );
  }

  void _showHolidayDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AttendanceStatusDialog(
        icon: AppAssets.iconInfo,
        title: 'Hari Ini Adalah Hari Libur',
        description:
            'Halaman presensi tidak tersedia,\nAnda tidak perlu melakukan presensi',
        buttonText: 'Tutup',
        onPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _showCheckOutUnavailableDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AttendanceStatusDialog(
        icon: AppAssets.iconInfo,
        title: 'Presensi Keluar Belum Tersedia',
        description: 'Presensi keluar hanya dapat\ndilakukan mulai pukul 17.00',
        buttonText: 'Tutup',
        onPressed: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  String _displayValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '-';
    return trimmed;
  }

  AttendanceUiState _attendanceStateFromHistories(
    List<AttendanceHistoryModel>? histories,
  ) {
    final today = DateTime.now();
    final todayHistory = histories?.where((history) {
      return history.date.year == today.year &&
          history.date.month == today.month &&
          history.date.day == today.day;
    }).firstOrNull;

    return AttendanceUiState(
      isHoliday: false,
      hasClockIn: todayHistory?.clockInTime != null,
      hasClockOut: todayHistory?.clockOutTime != null,
    );
  }

  bool _isCalendarHoliday(DateTime date, Set<DateTime> holidays) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return normalizedDate.weekday == DateTime.saturday ||
        normalizedDate.weekday == DateTime.sunday ||
        holidays.contains(normalizedDate);
  }
}
