import 'package:flutter/foundation.dart';

import '../router/route_name.dart';

bool isResetPasswordDeepLink(Uri uri) {
  return uri.scheme == 'sakti' && uri.host == 'reset-password';
}

String extractResetPasswordToken(Uri uri) {
  final queryToken =
      uri.queryParameters['access_token'] ?? uri.queryParameters['token'];
  if (queryToken != null && queryToken.trim().isNotEmpty) {
    return queryToken.trim();
  }

  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) return '';

  final queryStart = fragment.contains('?')
      ? fragment.substring(fragment.indexOf('?') + 1)
      : fragment;
  final parameters = Uri.splitQueryString(queryStart);
  return (parameters['access_token'] ?? parameters['token'] ?? '').trim();
}

String resetPasswordLocationFromUri(Uri uri) {
  final token = extractResetPasswordToken(uri);
  if (token.isEmpty) return RouteName.resetPassword;

  return '${RouteName.resetPassword}?access_token=${Uri.encodeQueryComponent(token)}';
}

void logResetPasswordDeepLink(String source, Uri uri) {
  debugPrint('$source reset password deep link full URL: $uri');
  debugPrint('$source reset password deep link scheme: ${uri.scheme}');
  debugPrint('$source reset password deep link host: ${uri.host}');
  debugPrint('$source reset password deep link path: ${uri.path}');
  debugPrint('$source reset password deep link query: ${uri.query}');
  debugPrint('$source reset password deep link fragment: ${uri.fragment}');
}
