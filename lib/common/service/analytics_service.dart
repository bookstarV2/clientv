import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    // Debug print for verification
    debugPrint('GA Event: $name');
    debugPrint('Parameters: $parameters');

    Map<String, Object>? finalParameters;
    if (parameters != null) {
      finalParameters = {};
      for (var item in parameters.entries) {
        if (item.value != null) {
          finalParameters[item.key] = item.value as Object;
        }
      }
    }
    await _analytics.logEvent(name: name, parameters: finalParameters);
  }

  static Future<void> logClick({
    required String screenName,
    required String widgetName,
    Map<String, Object?>? parameters,
  }) async {
    final eventName = 'click_${widgetName.replaceAll(' ', '_').toLowerCase()}';
    final eventParameters = {
      'screen_name': screenName,
      ...?parameters,
    };
    // Debug print for verification
    debugPrint('GA Click Event: $eventName');
    debugPrint('Parameters: $eventParameters');

    await logEvent(eventName, parameters: eventParameters);
  }
}
