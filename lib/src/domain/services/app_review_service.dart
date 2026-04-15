import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _openCountKey = 'app_open_count';
const _reviewRequestedKey = 'review_requested';
const _reviewThreshold = 3; // triggers on the 3rd open (> 2)

class AppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  /// Call this once on every app launch.
  /// Requests a review the first time the open count exceeds [_reviewThreshold].
  Future<void> trackOpenAndRequestIfEligible() async {
    final prefs = await SharedPreferences.getInstance();

    // Do nothing if we have already requested a review before.
    final alreadyRequested = prefs.getBool(_reviewRequestedKey) ?? false;
    if (alreadyRequested) return;

    final count = (prefs.getInt(_openCountKey) ?? 0) + 1;
    await prefs.setInt(_openCountKey, count);

    if (count >= _reviewThreshold) {
      // Mark as requested regardless so we don't retry on every subsequent launch.
      await prefs.setBool(_reviewRequestedKey, true);
      final available = await _inAppReview.isAvailable();
      if (available) {
        await _inAppReview.requestReview();
      }
    }
  }
}
