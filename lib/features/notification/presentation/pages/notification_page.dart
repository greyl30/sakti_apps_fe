import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(Backend):
    // Ambil daftar notifikasi dari API.
    final notifications = dummyHrdNotifications;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar halaman notifikasi.
            const LeaveTopBar(
              title: 'Notifikasi',
              subtitle: 'Pemberitahuan terkait presensi dan cuti',
              fallbackRoute: RouteName.home,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NotificationCard(
                      notification: notification,
                      onTap: () => context.push(
                        RouteName.notificationDetail,
                        extra: notification,
                      ),
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
