import 'package:dio/dio.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/notifikasi');

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/notifikasi/unread',
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/notifikasi/$notificationId/read',
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/notifikasi/read-all',
    );

    return response.data ?? <String, dynamic>{};
  }
}
