import 'package:shared_preferences/shared_preferences.dart';

/// Manages onboarding state flags for new user guidance.
class OnboardingService {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyDemoSeen = 'onboarding_demo_seen';

  static Future<bool> hasDemoBeenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDemoSeen) ?? false;
  }

  static Future<void> markDemoAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDemoSeen, true);
  }

  /// Whether the full onboarding flow (user setup + model config) is complete.
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }
}
