import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sentry_flutter/sentry_flutter.dart';

/// Publishes one Sentry feature flag.
typedef FeatureFlagSink = FutureOr<void> Function(String flag, bool value);

/// Sends the boolean Remote Config values to Sentry as feature flags, once.
///
/// This replaces `SentryFirebaseRemoteConfigIntegration` on purpose. That
/// integration also listens to `FirebaseRemoteConfig.onConfigUpdated`, and on
/// web the first access of that stream opens the realtime connection to
/// `firebaseremoteconfigrealtime.googleapis.com`. The integration listens
/// without an `onError` handler, so every failure of the connection (for
/// example a dropped connection in a background tab) became an uncaught
/// error. The app reads the values it fetched at start-up and never needs
/// live updates, so nothing here may touch `onConfigUpdated`.
abstract final class RemoteConfigFeatureFlags {
  /// Prefix that keeps the Remote Config flags apart from other flag sources.
  static const String flagPrefix = 'firebase:';

  /// Reports every boolean value of [firebaseRemoteConfig] as a feature flag.
  ///
  /// Call it after Sentry is initialized: before that, Sentry drops the flags.
  /// [addFeatureFlag] defaults to `Sentry.addFeatureFlag`.
  static Future<void> report(
    FirebaseRemoteConfig firebaseRemoteConfig, {
    FeatureFlagSink? addFeatureFlag,
  }) async {
    final sink = addFeatureFlag ?? Sentry.addFeatureFlag;
    final values = <String, String>{
      for (final entry in firebaseRemoteConfig.getAll().entries)
        entry.key: entry.value.asString(),
    };
    for (final entry in booleanFlags(values).entries) {
      await sink('$flagPrefix${entry.key}', entry.value);
    }
  }

  /// Returns the entries of [values] that are booleans (`true`, `false`, `1`
  /// or `0`, in any case). Every other value is not a feature flag.
  @visibleForTesting
  static Map<String, bool> booleanFlags(Map<String, String> values) {
    final flags = <String, bool>{};
    for (final entry in values.entries) {
      switch (entry.value.toLowerCase()) {
        case 'true' || '1':
          flags[entry.key] = true;
        case 'false' || '0':
          flags[entry.key] = false;
      }
    }
    return flags;
  }
}
