import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../attendance/presentation/utils/attendance_availability.dart';
import '../../../attendance/presentation/widgets/attendance_status_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data profil user login dari auth provider.
    final user = ref.watch(authProvider).user;
    final userId = user?.id;
    final role = userRoleFromPeran(user?.peran);
    final positionParts = [
      user?.levelJabatan ?? user?.peran,
      user?.divisi ?? user?.unit,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    final workConfig = ref.watch(attendanceWorkConfigProvider);
    final attendanceAvailability =
        ref.watch(attendanceAvailabilityProvider).valueOrNull ??
        loadingAttendanceAvailability;
    final unreadCount = userId == null
        ? const AsyncValue<int>.data(0)
        : ref.watch(notificationUnreadCountProvider(userId));
    final hasUnreadNotifications = (unreadCount.valueOrNull ?? 0) > 0;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryRed,
          onRefresh: () => _refreshHome(ref, role, userId),
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
                      isHoliday: attendanceAvailability.isCalendarHoliday,
                      canCheckIn: attendanceAvailability.canCheckIn,
                      canCheckOut: attendanceAvailability.canCheckOut,
                      onCheckInTap: () => _handleCheckInTap(
                        context,
                        unavailableReason:
                            attendanceAvailability.checkInUnavailableReason,
                      ),
                      onCheckOutTap: () => _handleCheckOutTap(
                        context,
                        unavailableReason:
                            attendanceAvailability.checkOutUnavailableReason,
                      ),
                      onScheduleTap: () => context.push(RouteName.calendar),
                      scheduleLabel: workConfig.valueOrNull?.workScheduleLabel,
                    ),
                    const SizedBox(height: 20),
                    HomeReminderSection(
                      isHoliday: attendanceAvailability.isCalendarHoliday,
                      checkInDeadlineLabel:
                          workConfig.valueOrNull?.onTimeDeadlineLabel,
                      onCheckInReminderTap: () => _handleCheckInTap(
                        context,
                        unavailableReason:
                            attendanceAvailability.checkInUnavailableReason,
                      ),
                      onCheckOutReminderTap: () => _handleCheckOutTap(
                        context,
                        unavailableReason:
                            attendanceAvailability.checkOutUnavailableReason,
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
    required AttendanceUnavailableReason? unavailableReason,
  }) {
    if (unavailableReason != null) {
      _showUnavailableDialog(context, unavailableReason);
      return;
    }

    context.push(RouteName.checkInVerification);
  }

  void _handleCheckOutTap(
    BuildContext context, {
    required AttendanceUnavailableReason? unavailableReason,
  }) {
    if (unavailableReason != null) {
      _showUnavailableDialog(context, unavailableReason);
      return;
    }

    context.push(RouteName.checkOutVerification);
  }

  Future<void> _refreshHome(
    WidgetRef ref,
    UserRole role,
    String? userId,
  ) async {
    ref.invalidate(attendanceAvailabilityProvider);
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
      ref.read(attendanceAvailabilityProvider.future).then((_) {}),
      ref.read(attendanceHistoriesProvider.future).then((_) {}),
      ref.read(activeLeaveHolidayDatesProvider.future).then((_) {}),
      ref.read(leaveStatusesProvider.future).then((_) {}),
      if (userId != null)
        ref.read(notificationsProvider(userId).notifier).refresh(),
      if (userId != null)
        ref.read(notificationUnreadCountProvider(userId).notifier).refresh(),
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

  void _showUnavailableDialog(
    BuildContext context,
    AttendanceUnavailableReason reason,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AttendanceStatusDialog(
        icon: AppAssets.iconInfo,
        title: reason.title,
        description: reason.message,
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
}
