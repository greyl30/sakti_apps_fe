import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../leave/presentation/widgets/leave_top_bar.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

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
              child: RefreshIndicator(
                color: AppColors.primaryRed,
                onRefresh: () => _refreshNotifications(ref),
                child: notifications.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const _NotificationMessageList(
                        'Belum ada notifikasi',
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final notification = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: NotificationCard(
                            notification: notification,
                            onTap: () => _openNotificationDetail(
                              context,
                              ref,
                              notification,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const _NotificationMessageList('Memuat notifikasi...'),
                  error: (error, stackTrace) => const _NotificationMessageList(
                    'Notifikasi belum dapat dimuat.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshNotifications(WidgetRef ref) async {
    await ref.read(notificationsProvider.notifier).refresh();
    await ref.read(notificationUnreadCountProvider.notifier).refresh();
  }

  Future<void> _openNotificationDetail(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    final isMarkedAsRead = notification.isRead
        ? true
        : await ref
              .read(notificationsProvider.notifier)
              .markAsRead(notification.id);

    if (!context.mounted) return;

    context.push(
      RouteName.notificationDetail,
      extra: isMarkedAsRead
          ? notification.copyWith(isRead: true)
          : notification,
    );
  }
}

class _NotificationMessageList extends StatelessWidget {
  const _NotificationMessageList(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 220),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A8F98),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
