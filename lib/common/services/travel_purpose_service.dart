import 'package:travel_assistant/common/models/travel_purpose.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';

/// Service for providing travel purpose data with localization and Firebase Remote Config support.
class TravelPurposeService {
  /// Creates a [TravelPurposeService] with required dependencies.
  TravelPurposeService({
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  }) : _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository;

  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  /// Returns all available travel purposes with localized names.
  List<TravelPurpose> getTravelPurposes() {
    // Get travel purposes from Firebase Remote Config (already decoded)
    final travelPurposesData = _firebaseRemoteConfigRepository.travelPurposes;

    // Convert to TravelPurpose objects with localized names
    return travelPurposesData.map((data) {
      return TravelPurpose(
        id: data['id'],
        name: data['name'],
        localizationKey: data['localizationKey'],
        icon: data['icon'],
      );
    }).toList();
  }
}
