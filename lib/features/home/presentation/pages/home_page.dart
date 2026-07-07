import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../widgets/home_attendance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_history_section.dart';
import '../widgets/home_reminder_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy state sementara sampai provider/backend presensi tersedia.
    // TODO: Ubah dummy state menjadi provider.
    const isCheckedIn = false;
    const canCheckOut = false;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HomeHeader(
              userName: 'Wijaya Kusuma',
              positionLabel: 'Staff | IT & Sistem Informasi',
              onProfileTap: () => context.push(RouteName.profile),
              onNotificationTap: () => context.push(RouteName.notification),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeAttendanceCard(
                    isCheckedIn: isCheckedIn,
                    canCheckOut: canCheckOut,
                    onAttendanceTap: () => context.push(RouteName.attendance),
                  ),
                  const SizedBox(height: 20),
                  HomeReminderSection(
                    onReminderTap: () => context.push(RouteName.attendance),
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}
