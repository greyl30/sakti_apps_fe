import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginRateLimitService {
  const LoginRateLimitService._();

  static const maxFailedAttempts = 5;
  static const cooldownDuration = Duration(minutes: 5);
  static const _attemptPrefix = 'login_failed_attempts_';
  static const _cooldownPrefix = 'login_cooldown_until_';

  static Future<DateTime?> cooldownUntil(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) return null;

    final preferences = await SharedPreferences.getInstance();
    final key = _cooldownKey(normalizedEmail);
    final timestamp = preferences.getInt(key);
    if (timestamp == null) return null;

    final cooldownEnd = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().isBefore(cooldownEnd)) return cooldownEnd;

    await reset(normalizedEmail);
    return null;
  }

  static Future<DateTime?> recordFailure(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) return null;

    final existingCooldown = await cooldownUntil(normalizedEmail);
    if (existingCooldown != null) return existingCooldown;

    final preferences = await SharedPreferences.getInstance();
    final attemptKey = _attemptKey(normalizedEmail);
    final failedAttempts = preferences.getInt(attemptKey) ?? 0;
    final nextAttempts = failedAttempts + 1;

    if (nextAttempts >= maxFailedAttempts) {
      final cooldownEnd = DateTime.now().add(cooldownDuration);
      await preferences.setInt(
        _cooldownKey(normalizedEmail),
        cooldownEnd.millisecondsSinceEpoch,
      );
      await preferences.setInt(attemptKey, nextAttempts);
      return cooldownEnd;
    }

    await preferences.setInt(attemptKey, nextAttempts);
    return null;
  }

  static Future<void> reset(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_attemptKey(normalizedEmail));
    await preferences.remove(_cooldownKey(normalizedEmail));
  }

  static String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String _attemptKey(String email) {
    return '$_attemptPrefix${_emailKey(email)}';
  }

  static String _cooldownKey(String email) {
    return '$_cooldownPrefix${_emailKey(email)}';
  }

  static String _emailKey(String email) {
    return base64Url.encode(utf8.encode(email));
  }
}
