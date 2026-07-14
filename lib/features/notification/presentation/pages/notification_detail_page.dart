import 'package:flutter/material.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/notification_model.dart';
import '../widgets/notification_detail_card.dart';

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top AppBar detail notifikasi.
            const LeaveTopBar(
              title: 'Notifikasi',
              subtitle: 'Pemberitahuan terkait presensi dan cuti',
              fallbackRoute: RouteName.notification,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                children: [NotificationDetailCard(notification: notification)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
