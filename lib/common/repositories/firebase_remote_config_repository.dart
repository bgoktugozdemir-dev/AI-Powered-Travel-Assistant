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
  static final Map<String, dynamic> defaults = {
    RemoteConfigs.unsplashClientId.key: '',
    RemoteConfigs.minimumTravelPurposes.key: 1,
    RemoteConfigs.maximumTravelPurposes.key: 3,
  };

  /// Key for the Unsplash Client ID.
  static const String unsplashClientIdKey = 'unsplash_client_id';

  /// Minimum number of travel purposes.
  static const String minimumTravelPurposesKey = 'minimum_travel_purposes';

  /// Maximum number of travel purposes.
  static const String maximumTravelPurposesKey = 'maximum_travel_purposes';
}

enum RemoteConfigs {
  unsplashClientId(key: _Constants.unsplashClientIdKey),
  minimumTravelPurposes(key: _Constants.minimumTravelPurposesKey),
  maximumTravelPurposes(key: _Constants.maximumTravelPurposesKey);

  const RemoteConfigs({required this.key});

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
  String get unsplashClientId => _firebaseRemoteConfig.getString(RemoteConfigs.unsplashClientId.key);

  /// Fetches the minimum number of travel purposes from Firebase Remote Config.
  ///
  /// Returns the minimum number of travel purposes if available, otherwise 1.
  int get minimumTravelPurposes => _firebaseRemoteConfig.getInt(RemoteConfigs.minimumTravelPurposes.key);

  /// Fetches the maximum number of travel purposes from Firebase Remote Config.
  ///
  /// Returns the maximum number of travel purposes if available, otherwise 3.
  int get maximumTravelPurposes => _firebaseRemoteConfig.getInt(RemoteConfigs.maximumTravelPurposes.key);
}
