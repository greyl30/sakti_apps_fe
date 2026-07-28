import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
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
      return NotificationsNotifier(repository)..load();
    });

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsNotifier(this._repository) : super(const AsyncValue.loading());

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
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<NotificationModel>> _fetchNotifications() async {
    final notifications = await _repository.getNotifications();

    return notifications
        .map((notification) => notification.toPresentationModel())
        .toList();
  }
}
