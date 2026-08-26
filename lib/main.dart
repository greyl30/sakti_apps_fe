import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/app_navigation.dart';
import 'core/deep_link/reset_password_deep_link_service.dart';
import 'core/firebase/firebase_messaging_service.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/router/route_name.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Firebase.initializeApp();
  await AppFirebaseMessagingService.initialize();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final providerContainer = ProviderContainer();
  ApiClient.onAccountInactive = (message) async {
    await providerContainer
        .read(authProvider.notifier)
        .handleAccountInactive(message);
    appRouter.go(RouteName.login);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = rootScaffoldMessengerKey.currentState;
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  };

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ResetPasswordDeepLinkService.initialize();
  });
}
