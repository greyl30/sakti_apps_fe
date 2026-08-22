import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
  String? _markedAllAsReadUserId;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider.select((state) => state.user?.id));
    final notifications = userId == null
        ? const PaginatedNotificationsState(hasMore: false)
        : ref.watch(notificationsProvider(userId));

    if (userId != null && _markedAllAsReadUserId != userId) {
      _markedAllAsReadUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(notificationsProvider(userId).notifier).markAllAsRead();
      });
    }

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
                onRefresh: () => _refreshNotifications(ref, userId),
                child: _buildNotificationList(notifications, userId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    PaginatedNotificationsState notifications,
    String? userId,
  ) {
    if (notifications.isLoading && notifications.items.isEmpty) {
      return const _NotificationMessageList('Memuat notifikasi...');
    }

    if (notifications.errorMessage != null && notifications.items.isEmpty) {
      return _NotificationMessageList(notifications.errorMessage!);
    }

    if (notifications.items.isEmpty && !notifications.hasMore) {
      return const _NotificationMessageList('Belum ada notifikasi');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      itemCount: notifications.items.length + (notifications.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == notifications.items.length) {
          return _LoadMoreNotificationsAction(
            isLoading: notifications.isLoadingMore,
            onTap: userId == null
                ? () {}
                : () => ref
                      .read(notificationsProvider(userId).notifier)
                      .loadMore(),
          );
        }

        final notification = notifications.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: NotificationCard(
            notification: notification,
            onTap: () =>
                _openNotificationDetail(context, ref, notification, userId),
          ),
        );
      },
    );
  }

  Future<void> _refreshNotifications(WidgetRef ref, String? userId) async {
    if (userId == null) return;

    await ref.read(notificationsProvider(userId).notifier).refresh();
    await ref.read(notificationUnreadCountProvider(userId).notifier).refresh();
  }

  Future<void> _openNotificationDetail(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
    String? userId,
  ) async {
    if (userId == null) return;

    final isMarkedAsRead = notification.isRead
        ? true
        : await ref
              .read(notificationsProvider(userId).notifier)
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

class _LoadMoreNotificationsAction extends StatelessWidget {
  const _LoadMoreNotificationsAction({
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
