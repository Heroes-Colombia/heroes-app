import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state for first-time users
class OnboardingService {
  static const String _introScreenShownKey = 'intro_screen_shown';
  static const String _showcaseShownKey = 'showcase_shown';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// Check if the introduction screen has been shown
  bool get hasSeenIntroScreen {
    return _prefs.getBool(_introScreenShownKey) ?? false;
  }

  /// Check if the showcase tutorial has been shown
  bool get hasSeenShowcase {
    return _prefs.getBool(_showcaseShownKey) ?? false;
  }

  /// Mark introduction screen as shown
  Future<void> setIntroScreenShown() async {
    await _prefs.setBool(_introScreenShownKey, true);
  }

  /// Mark showcase tutorial as shown
  Future<void> setShowcaseShown() async {
    await _prefs.setBool(_showcaseShownKey, true);
  }

  /// Reset all onboarding flags (useful for testing)
  Future<void> resetOnboarding() async {
    await _prefs.remove(_introScreenShownKey);
    await _prefs.remove(_showcaseShownKey);
  }
}
