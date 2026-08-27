import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../router/app_router.dart';
import 'reset_password_deep_link_parser.dart';

class ResetPasswordDeepLinkService {
  ResetPasswordDeepLinkService._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _subscription;
  static Future<void>? _initializeFuture;
  static bool _isHandlingResetPasswordLink = false;

  static bool get isHandlingResetPasswordLink => _isHandlingResetPasswordLink;

  static Future<void> initialize() async {
    if (_initializeFuture != null) return _initializeFuture;

    _initializeFuture = _initialize();
    return _initializeFuture;
  }

  static Future<void> _initialize() async {
    await _handleInitialLink();
    _subscription ??= _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Reset password deep link stream error: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  static Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      debugPrint('Reset password initial deep link available: ${uri != null}');
      if (uri != null) {
        _handleUri(uri, source: 'Initial');
      }
    } catch (error, stackTrace) {
      debugPrint('Reset password initial deep link error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static void _handleUri(Uri uri, {String source = 'Runtime'}) {
    logResetPasswordDeepLink(source, uri);

    if (!isResetPasswordDeepLink(uri)) return;

    _isHandlingResetPasswordLink = true;
    final token = extractResetPasswordToken(uri);
    final location = resetPasswordLocationFromUri(uri);

    debugPrint(
      '$source reset password deep link token found: ${token.isNotEmpty}',
    );
    debugPrint('$source reset password deep link navigating to reset page.');

    appRouter.go(location);
  }
}
