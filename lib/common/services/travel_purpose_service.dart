import 'package:flutter/material.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart';

/// Service for providing travel purpose data.
class TravelPurposeService {
  /// List of standard travel purposes
  static final List<TravelPurpose> _travelPurposes = [
    TravelPurpose(id: 'sightseeing', name: 'Sightseeing', icon: 'photo_camera'),
    TravelPurpose(id: 'food', name: 'Local Food', icon: 'restaurant'),
    TravelPurpose(id: 'business', name: 'Business', icon: 'business_center'),
    TravelPurpose(id: 'friends', name: 'Visiting Friends', icon: 'people'),
    TravelPurpose(id: 'family', name: 'Family Visit', icon: 'family_restroom'),
    TravelPurpose(id: 'adventure', name: 'Adventure', icon: 'hiking'),
    TravelPurpose(id: 'relaxation', name: 'Relaxation', icon: 'beach_access'),
    TravelPurpose(id: 'cultural', name: 'Cultural Experience', icon: 'museum'),
    TravelPurpose(id: 'shopping', name: 'Shopping', icon: 'shopping_bag'),
    TravelPurpose(id: 'education', name: 'Education', icon: 'school'),
    TravelPurpose(id: 'sports', name: 'Sports & Activities', icon: 'sports'),
    TravelPurpose(id: 'medical', name: 'Medical Tourism', icon: 'medical_services'),
    TravelPurpose(id: 'honeymoon', name: 'Honeymoon', icon: 'favorite'),
    TravelPurpose(id: 'religious', name: 'Religious Pilgrimage', icon: 'church'),
  ];

  /// Returns all available travel purposes.
  Future<List<TravelPurpose>> getTravelPurposes() async {
    // In a real app, this might fetch from an API
    await Future.delayed(const Duration(milliseconds: 300));
    return _travelPurposes;
  }

  /// Returns the icon data for a travel purpose based on its icon name
  static IconData getIconForPurpose(String? iconName) {
    if (iconName == null) {
      return Icons.category;
    }
    
    switch (iconName) {
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
      default:
        return Icons.category;
    }
  }
} 