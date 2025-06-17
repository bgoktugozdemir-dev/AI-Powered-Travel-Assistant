import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

part 'travel_purpose.freezed.dart';
part 'travel_purpose.g.dart';

/// Represents a travel purpose with id, name, and icon.
@freezed
abstract class TravelPurpose with _$TravelPurpose {
  /// Private constructor needed for custom methods
  const TravelPurpose._();

  /// Creates a [TravelPurpose] instance.
  ///
  /// Requires [id] and [name].
  /// [localizationKey] is used for getting localized names.
  const factory TravelPurpose({
    required String id,
    required String name,
    required String localizationKey,
    String? icon,
  }) = _TravelPurpose;

  /// Creates a [TravelPurpose] instance from a JSON object.
  factory TravelPurpose.fromJson(Map<String, dynamic> json) => _$TravelPurposeFromJson(json);
}

extension TravelPurposeExtension on TravelPurpose {
  String getLocalizedName(AppLocalizations l10n) {
    try {
      switch (localizationKey) {
        case 'travelPurposeSightseeing':
          return l10n.travelPurposeSightseeing;
        case 'travelPurposeFood':
          return l10n.travelPurposeFood;
        case 'travelPurposeBusiness':
          return l10n.travelPurposeBusiness;
        case 'travelPurposeFriends':
          return l10n.travelPurposeFriends;
        case 'travelPurposeFamily':
          return l10n.travelPurposeFamily;
        case 'travelPurposeAdventure':
          return l10n.travelPurposeAdventure;
        case 'travelPurposeRelaxation':
          return l10n.travelPurposeRelaxation;
        case 'travelPurposeCultural':
          return l10n.travelPurposeCultural;
        case 'travelPurposeShopping':
          return l10n.travelPurposeShopping;
        case 'travelPurposeEducation':
          return l10n.travelPurposeEducation;
        case 'travelPurposeSports':
          return l10n.travelPurposeSports;
        case 'travelPurposeMedical':
          return l10n.travelPurposeMedical;
        case 'travelPurposeHoneymoon':
          return l10n.travelPurposeHoneymoon;
        case 'travelPurposeReligious':
          return l10n.travelPurposeReligious;
        case 'travelPurposePhotoSpots':
          return l10n.travelPurposePhotoSpots;
        case 'travelPurposeNightlife':
          return l10n.travelPurposeNightlife;
        case 'travelPurposeNature':
          return l10n.travelPurposeNature;
        case 'travelPurposeFestivals':
          return l10n.travelPurposeFestivals;
        default:
          return name;
      }
    } catch (_) {
      return name;
    }
  }

  /// Returns the icon data for a travel purpose based on its icon name.
  ///
  /// If the icon is null, returns [Icons.category].
  IconData getIconData() {
    if (icon == null) {
      return Icons.category;
    }

    switch (icon) {
      case 'photo_camera':
        return Icons.photo_camera;
      case 'restaurant':
        return Icons.restaurant;
      case 'business_center':
        return Icons.business_center;
      case 'people':
        return Icons.people;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'hiking':
        return Icons.hiking;
      case 'beach_access':
        return Icons.beach_access;
      case 'museum':
        return Icons.museum;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'school':
        return Icons.school;
      case 'sports':
        return Icons.sports;
      case 'medical_services':
        return Icons.medical_services;
      case 'favorite':
        return Icons.favorite;
      case 'church':
        return Icons.church;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'nightlife':
        return Icons.nightlife;
      case 'nature':
        return Icons.nature;
      case 'festival':
        return Icons.festival;
      default:
        return Icons.category;
    }
  }
}
