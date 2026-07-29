import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../supabase/supabase_client.dart';
import 'datasources/fcm_remote_data_source.dart';
import 'models/fcm_token_registration_request.dart';
import 'repositories/fcm_repository.dart';

class AppFirebaseMessagingService {
  const AppFirebaseMessagingService._();

  static final FcmRepository _repository = FcmRepository(
    FcmRemoteDataSource(ApiClient.dio),
  );

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
      'FCM notification permission: ${settings.authorizationStatus.name}',
    );

    await _logCurrentToken(messaging);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed: $token');
      registerToken(token);
    });
  }

  static Future<void> registerCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM register skipped: token belum tersedia.');
        return;
      }

      await registerToken(token);
    } catch (error, stackTrace) {
      debugPrint('FCM register current token gagal: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> registerToken(String token) async {
    if (token.isEmpty) {
      debugPrint('FCM register skipped: token kosong.');
      return;
    }

    final session = AppSupabaseClient.client.auth.currentSession;
    if (session == null) {
      debugPrint('FCM register skipped: session belum tersedia.');
      return;
    }

    try {
      await _repository.registerToken(
        FcmTokenRegistrationRequest(fcmToken: token),
      );
      debugPrint('FCM token berhasil didaftarkan.');
    } catch (error, stackTrace) {
      debugPrint('FCM token gagal didaftarkan: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> _logCurrentToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM token belum tersedia.');
        return;
      }

      debugPrint('FCM token: $token');
    } catch (error, stackTrace) {
      debugPrint('Gagal mengambil FCM token: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
