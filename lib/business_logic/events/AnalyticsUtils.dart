// utils/analytics.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsUtils {
  final FirebaseAnalytics analytics;

  AnalyticsUtils(this.analytics);

  Future<void> logUserScore(String userId, int score) async {
    await analytics.logEvent(
      name: 'user_score',
      parameters: {
        'user_id': userId,
        'score': score,
      },
    );
  }

  Future<void> setPreferredTheme(String theme) async {
    await analytics.setUserProperty(
      name: 'preferred_theme',
      value: theme,
    );
  }
}