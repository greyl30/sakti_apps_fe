import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../attendance/presentation/utils/attendance_reminder_guard.dart';
import '../../../leave/data/models/leave_request_model.dart';
import '../../../leave/presentation/providers/leave_submit_provider.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_response_model.dart';
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

final notificationsProvider = StateNotifierProvider.autoDispose
    .family<NotificationsNotifier, PaginatedNotificationsState, String>((
      ref,
      userId,
    ) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationsNotifier(ref, repository, userId)..load();
    });

final notificationUnreadCountProvider = StateNotifierProvider.autoDispose
    .family<NotificationUnreadCountNotifier, AsyncValue<int>, String>((
      ref,
      userId,
    ) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationUnreadCountNotifier(repository)..load();
    });

class PaginatedNotificationsState {
  const PaginatedNotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<NotificationModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  PaginatedNotificationsState copyWith({
    List<NotificationModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaginatedNotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationsNotifier extends StateNotifier<PaginatedNotificationsState> {
  NotificationsNotifier(this._ref, this._repository, this._userId)
    : super(const PaginatedNotificationsState(isLoading: true));

  static const _limit = 10;

  final Ref _ref;
  final NotificationRepository _repository;
  final String _userId;
  int _page = 0;

  Future<void> load() async {
    _page = 0;
    state = const PaginatedNotificationsState(isLoading: true);
    await _loadPage(1, append: false);
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _loadPage(_page + 1, append: true);
  }

  Future<void> _loadPage(int page, {required bool append}) async {
    try {
      final response = await _repository.getNotificationPage(
        page: page,
        limit: _limit,
      );
      final notifications = await _mapNotifications(response.items);
      _page = response.page;
      state = PaginatedNotificationsState(
        items: append
            ? _uniqueNotifications([...state.items, ...notifications])
            : _uniqueNotifications(notifications),
        hasMore: response.hasMore,
      );
    } on NotificationException catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Gagal mengambil notifikasi.',
      );
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      state = state.copyWith(
        items: state.items
            .map(
              (notification) => notification.id == notificationId
                  ? notification.copyWith(isRead: true)
                  : notification,
            )
            .toList(),
      );
      await _ref
          .read(notificationUnreadCountProvider(_userId).notifier)
          .refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      state = state.copyWith(
        items: state.items
            .map((notification) => notification.copyWith(isRead: true))
            .toList(),
      );
      _ref.read(notificationUnreadCountProvider(_userId).notifier).setCount(0);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<NotificationModel>> _mapNotifications(
    List<NotificationResponseModel> notifications,
  ) async {
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

  List<NotificationModel> _uniqueNotifications(
    List<NotificationModel> notifications,
  ) {
    final seenIds = <String>{};
    final uniqueNotifications = <NotificationModel>[];

    for (final notification in notifications) {
      final key = notification.id.trim().isNotEmpty
          ? notification.id
          : '${notification.title}-${notification.createdAt.toIso8601String()}';
      if (!seenIds.add(key)) continue;

      uniqueNotifications.add(notification);
    }

    return uniqueNotifications;
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
