import 'package:dio/dio.dart';

import '../models/telegram_connect_request.dart';

class TelegramRemoteDataSource {
  const TelegramRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/telegram/status',
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> connect(TelegramConnectRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/telegram/connect',
      data: request.toJson(),
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> disconnect() async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/api/telegram/disconnect',
    );

    return response.data ?? <String, dynamic>{};
  }
}
