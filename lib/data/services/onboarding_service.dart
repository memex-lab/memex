import 'package:shared_preferences/shared_preferences.dart';

/// Manages onboarding state flags for new user guidance.
class OnboardingService {
  static const _keyFirstPostDone = 'onboarding_first_post_done';
  static const _keyInsightRefreshDone = 'onboarding_insight_refresh_done';
  static const _keyOnboardingComplete = 'onboarding_complete';

  /// Whether the full onboarding flow (user setup + model config) is complete.
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  static Future<bool> isFirstPostDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstPostDone) ?? false;
  }

  static Future<void> markFirstPostDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstPostDone, true);
  }

  static Future<bool> isInsightRefreshDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyInsightRefreshDone) ?? false;
  }

  static Future<void> markInsightRefreshDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInsightRefreshDone, true);
  }
}
