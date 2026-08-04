import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorageService {
  const OnboardingStorageService._();

  static const _completedKey = 'hasCompletedOnboarding';

  static Future<bool> hasCompletedOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_completedKey) ?? false;
  }

  static Future<void> setCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_completedKey, true);
  }
}
