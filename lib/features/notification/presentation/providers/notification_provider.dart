import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../attendance/presentation/utils/attendance_reminder_guard.dart';
import '../../../leave/data/models/leave_request_model.dart';
import '../../../leave/presentation/providers/leave_submit_provider.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository.dart';
import '../models/notification_model.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(ApiClient.dio);
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepository(remoteDataSource);
});

final notificationsProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationsNotifier(ref, repository)..load();
    });

final notificationUnreadCountProvider =
    StateNotifierProvider<NotificationUnreadCountNotifier, AsyncValue<int>>((
      ref,
    ) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationUnreadCountNotifier(repository)..load();
    });

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsNotifier(this._ref, this._repository)
    : super(const AsyncValue.loading());

  final Ref _ref;
  final NotificationRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _fetchNotifications());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    try {
      state = AsyncValue.data(await _fetchNotifications());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final currentItems = state.valueOrNull;
      if (currentItems != null) {
        state = AsyncValue.data(
          currentItems
              .map(
                (notification) => notification.id == notificationId
                    ? notification.copyWith(isRead: true)
                    : notification,
              )
              .toList(),
        );
      }
      await _ref.read(notificationUnreadCountProvider.notifier).refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      final currentItems = state.valueOrNull;
      if (currentItems != null) {
        state = AsyncValue.data(
          currentItems
              .map((notification) => notification.copyWith(isRead: true))
              .toList(),
        );
      }
      _ref.read(notificationUnreadCountProvider.notifier).setCount(0);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<NotificationModel>> _fetchNotifications() async {
    final notifications = await _repository.getNotifications();
    final holidays = await _ref.read(activeLeaveHolidayDatesProvider.future);
    final leaveStatuses = await _ref.read(leaveStatusesProvider.future);

    return notifications
        .map((notification) => notification.toPresentationModel())
        .where(
          (notification) => !_shouldSuppressAttendanceNotification(
            notification,
            holidays: holidays,
            leaveStatuses: leaveStatuses,
          ),
        )
        .toList();
  }

  bool _shouldSuppressAttendanceNotification(
    NotificationModel notification, {
    required Set<DateTime> holidays,
    required List<LeaveRequestResponse> leaveStatuses,
  }) {
    if (notification.type != NotificationType.checkIn &&
        notification.type != NotificationType.checkOut) {
      return false;
    }

    return isAttendanceReminderSuppressed(
      date: notification.createdAt,
      holidays: holidays,
      leaveRequests: leaveStatuses,
    );
  }
}

class NotificationUnreadCountNotifier extends StateNotifier<AsyncValue<int>> {
  NotificationUnreadCountNotifier(this._repository)
    : super(const AsyncValue.loading());

  final NotificationRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    await refresh();
  }

  Future<void> refresh() async {
    try {
      state = AsyncValue.data(await _repository.getUnreadCount());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void setCount(int count) {
    state = AsyncValue.data(count < 0 ? 0 : count);
  }
}
