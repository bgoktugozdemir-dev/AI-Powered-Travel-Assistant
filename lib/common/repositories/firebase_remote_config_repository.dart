import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

abstract class _Constants {
  /// Timeout for fetching the config.
  static const Duration fetchTimeout = Duration(minutes: 1);

  /// Fetch up to 5 times per hour.
  static const Duration minimumFetchInterval = Duration(minutes: 12);

  /// Fetch immediately.
  static const Duration minimumFetchIntervalForDevelopment = Duration.zero;

  /// Defaults for the config.
  static final Map<String, dynamic> defaults = {FirebaseRemoteConfigKeys.unsplashClientId.key: ''};

  /// Key for the Unsplash Client ID.
  static const String unsplashClientIdKey = 'unsplash_client_id';
}

enum FirebaseRemoteConfigKeys {
  unsplashClientId(key: _Constants.unsplashClientIdKey);

  const FirebaseRemoteConfigKeys({required this.key});

  final String key;
}

/// Repository for accessing Firebase Remote Config values.
class FirebaseRemoteConfigRepository {
  FirebaseRemoteConfigRepository({required FirebaseRemoteConfig firebaseRemoteConfig})
    : _firebaseRemoteConfig = firebaseRemoteConfig;

  final FirebaseRemoteConfig _firebaseRemoteConfig;

  Future<void> initialize() async {
    try {
      /// Set the config settings.
      await _setConfigSettings();

      /// Set the defaults.
      await _setDefaults();

      /// Fetch and activate the config.
      await _fetchAndActivate();
    } catch (e) {
      appLogger.e('Error initializing Firebase Remote Config', error: e);
    }
  }

  Future<void> _setConfigSettings() async {
    final settings = RemoteConfigSettings(
      fetchTimeout: _Constants.fetchTimeout,
      minimumFetchInterval:
          kDebugMode ? _Constants.minimumFetchIntervalForDevelopment : _Constants.minimumFetchInterval,
    );
    await _firebaseRemoteConfig.setConfigSettings(settings);
  }

  Future<void> _setDefaults() async {
    await _firebaseRemoteConfig.setDefaults(_Constants.defaults);
  }

  Future<void> _fetchAndActivate() async {
    await _firebaseRemoteConfig.fetchAndActivate();
  }

  /// Fetches the Unsplash Client ID from Firebase Remote Config.
  ///
  /// Returns the client ID string if available, otherwise an empty string.
  String get unsplashClientId => _firebaseRemoteConfig.getString(FirebaseRemoteConfigKeys.unsplashClientId.key);
}
