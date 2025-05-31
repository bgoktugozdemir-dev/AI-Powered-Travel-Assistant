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
  static final Map<String, dynamic> defaults = Map.fromEntries(
    RemoteConfigs.values.map((e) => MapEntry(e.key, e.defaultValue)),
  );
}

enum RemoteConfigs {
  /// Key for the AI model.
  aiModel(key: 'ai_model', defaultValue: 'gemini-2.0-flash'),

  /// Key for the AI system prompt.
  aiSystemPrompt(key: 'ai_system_prompt', defaultValue: ''),

  /// Key for the Recaptcha site key.
  recaptchaSiteKey(key: 'recaptcha_site_key', defaultValue: ''),

  /// Key for the Unsplash Client ID.
  unsplashClientId(key: 'unsplash_client_id', defaultValue: ''),

  /// Key for the Free Currency API key.
  freeCurrencyApiKey(key: 'free_currency_api_key', defaultValue: ''),

  /// Key for the cache free currency api data.
  cacheFreeCurrencyApiData(key: 'cache_free_currency_api_data', defaultValue: true),

  /// Navigate to next step after selecting travel purpose.
  navigateToNextStepAfterSelectingTravelPurpose(
    key: 'navigate_to_next_step_after_selecting_travel_purpose',
    defaultValue: false,
  ),

  /// Minimum number of travel purposes.
  minimumTravelPurposes(key: 'minimum_travel_purposes', defaultValue: 1),

  /// Maximum number of travel purposes.
  maximumTravelPurposes(key: 'maximum_travel_purposes', defaultValue: 3),

  /// Show city view.
  showCityView(key: 'show_city_view', defaultValue: false),

  /// Show city card.
  showCityCard(key: 'show_city_card', defaultValue: true),

  /// Show required documents card.
  showRequiredDocumentsCard(key: 'show_required_documents_card', defaultValue: true),

  /// Show currency card.
  showCurrencyCard(key: 'show_currency_card', defaultValue: true),

  /// Show flight options card.
  showFlightOptionsCard(key: 'show_flight_options_card', defaultValue: false),

  /// Show tax information card.
  showTaxInfoCard(key: 'show_tax_info_card', defaultValue: true),

  /// Show top spots card.
  showTopSpotsCard(key: 'show_top_spots_card', defaultValue: true),

  /// Show travel plan card.
  showTravelPlanCard(key: 'show_travel_plan_card', defaultValue: true),

  /// Show recommendations card.
  showRecommendationsCard(key: 'show_recommendations_card', defaultValue: true);

  const RemoteConfigs({required this.key, required this.defaultValue});

  final String key;
  final dynamic defaultValue;
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

  /// Fetches the AI model from Firebase Remote Config.
  ///
  /// Returns the AI model string if available, otherwise the default model.
  String get aiModel => _firebaseRemoteConfig.getString(RemoteConfigs.aiModel.key);

  /// Fetches the AI system prompt from Firebase Remote Config.
  ///
  /// Returns the AI system prompt string if available, otherwise an empty string.
  String get aiSystemPrompt => _firebaseRemoteConfig.getString(RemoteConfigs.aiSystemPrompt.key);

  /// Fetches the Recaptcha site key from Firebase Remote Config.
  ///
  /// Returns the Recaptcha site key string if available, otherwise an empty string.
  String get recaptchaSiteKey => _firebaseRemoteConfig.getString(RemoteConfigs.recaptchaSiteKey.key);

  /// Fetches the Unsplash Client ID from Firebase Remote Config.
  ///
  /// Returns the client ID string if available, otherwise an empty string.
  String get unsplashClientId => _firebaseRemoteConfig.getString(RemoteConfigs.unsplashClientId.key);

  /// Fetches the Free Currency API key from Firebase Remote Config.
  ///
  /// Returns the API key string if available, otherwise an empty string.
  String get freeCurrencyApiKey => _firebaseRemoteConfig.getString(RemoteConfigs.freeCurrencyApiKey.key);

  /// Fetches the cache free currency api data from Firebase Remote Config.
  ///
  /// Returns true if the cache free currency api data should be cached, otherwise true.
  bool get cacheFreeCurrencyApiData => _firebaseRemoteConfig.getBool(RemoteConfigs.cacheFreeCurrencyApiData.key);

  /// Fetches the minimum number of travel purposes from Firebase Remote Config.
  ///
  /// Returns the minimum number of travel purposes if available, otherwise 1.
  int get minimumTravelPurposes => _firebaseRemoteConfig.getInt(RemoteConfigs.minimumTravelPurposes.key);

  /// Fetches the maximum number of travel purposes from Firebase Remote Config.
  ///
  /// Returns the maximum number of travel purposes if available, otherwise 3.
  int get maximumTravelPurposes => _firebaseRemoteConfig.getInt(RemoteConfigs.maximumTravelPurposes.key);

  /// Fetches the show city view from Firebase Remote Config.
  ///
  /// Returns true if the city view should be shown, otherwise false.
  bool get showCityView => _firebaseRemoteConfig.getBool(RemoteConfigs.showCityView.key);

  /// Fetches the show city card from Firebase Remote Config.
  ///
  /// Returns true if the city card should be shown, otherwise true.
  bool get showCityCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showCityCard.key);

  /// Fetches the show required documents card from Firebase Remote Config.
  ///
  /// Returns true if the required documents card should be shown, otherwise true.
  bool get showRequiredDocumentsCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showRequiredDocumentsCard.key);

  /// Fetches the show currency card from Firebase Remote Config.
  ///
  /// Returns true if the currency card should be shown, otherwise true.
  bool get showCurrencyCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showCurrencyCard.key);

  /// Fetches the show flight options card from Firebase Remote Config.
  ///
  /// Returns true if the flight options card should be shown, otherwise false.
  bool get showFlightOptionsCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showFlightOptionsCard.key);

  /// Fetches the show tax information card from Firebase Remote Config.
  ///
  /// Returns true if the tax information card should be shown, otherwise true.
  bool get showTaxInfoCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showTaxInfoCard.key);

  /// Fetches the show top spots card from Firebase Remote Config.
  ///
  /// Returns true if the top spots card should be shown, otherwise true.
  bool get showTopSpotsCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showTopSpotsCard.key);

  /// Fetches the show travel plan card from Firebase Remote Config.
  ///
  /// Returns true if the travel plan card should be shown, otherwise true.
  bool get showTravelPlanCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showTravelPlanCard.key);

  /// Fetches the show recommendations card from Firebase Remote Config.
  ///
  /// Returns true if the recommendations card should be shown, otherwise true.
  bool get showRecommendationsCard => _firebaseRemoteConfig.getBool(RemoteConfigs.showRecommendationsCard.key);

  /// Fetches the navigate to next step after selecting travel purpose from Firebase Remote Config.
  ///
  /// Returns true if the navigate to next step after selecting travel purpose should be shown, otherwise false.
  bool get navigateToNextStepAfterSelectingTravelPurpose =>
      _firebaseRemoteConfig.getBool(RemoteConfigs.navigateToNextStepAfterSelectingTravelPurpose.key);
}
