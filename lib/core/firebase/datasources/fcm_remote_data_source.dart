import 'package:dio/dio.dart';

import '../models/fcm_token_registration_request.dart';

class FcmRemoteDataSource {
  const FcmRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> registerToken(
    FcmTokenRegistrationRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/fcm/register',
      data: request.toJson(),
    );

    return response.data ?? <String, dynamic>{};
  }
}
