import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:travel_assistant/common/models/country.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

/// Service for providing country data.
/// Fetches country data from a remote API and provides methods to search and filter.
class CountryService {
  static const String _countryApiUrl =
      'https://raw.githubusercontent.com/Imagin-io/country-nationality-list/refs/heads/master/countries.json';

  final Dio _dio;
  List<Country> _countries = [];
  bool _isInitialized = false;

  /// Creates a [CountryService] with an optional [Dio] instance.
  CountryService({Dio? dio}) : _dio = dio ?? Dio();

  /// Initialize the service by fetching countries from the API.
  /// This should be called before using the service.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final response = await _dio.get(_countryApiUrl);
      final List<dynamic> jsonData = jsonDecode(response.data);

      _countries =
          jsonData
              .map(
                (item) => Country(
                  code: item['alpha_2_code'] as String,
                  name: item['en_short_name'] as String,
                  nationality: item['nationality'] as String?,
                  flagEmoji: _getFlagEmoji(item['alpha_2_code'] as String),
                ),
              )
              .toList();

      _isInitialized = true;
      appLogger.i('CountryService initialized with ${_countries.length} countries');
    } catch (e) {
      appLogger.e('Failed to initialize CountryService', error: e);
      _initializeFallbackData();
    }
  }

  /// Initialize with fallback data in case API fails
  void _initializeFallbackData() {
    _countries = [
      Country(code: 'US', name: 'United States', nationality: 'American', flagEmoji: '🇺🇸'),
      Country(code: 'GB', name: 'United Kingdom', nationality: 'British', flagEmoji: '🇬🇧'),
      Country(code: 'TR', name: 'Turkey', nationality: 'Turkish', flagEmoji: '🇹🇷'),
      Country(code: 'DE', name: 'Germany', nationality: 'German', flagEmoji: '🇩🇪'),
      Country(code: 'FR', name: 'France', nationality: 'French', flagEmoji: '🇫🇷'),
      Country(code: 'IT', name: 'Italy', nationality: 'Italian', flagEmoji: '🇮🇹'),
      Country(code: 'ES', name: 'Spain', nationality: 'Spanish', flagEmoji: '🇪🇸'),
      Country(code: 'JP', name: 'Japan', nationality: 'Japanese', flagEmoji: '🇯🇵'),
      Country(code: 'CN', name: 'China', nationality: 'Chinese', flagEmoji: '🇨🇳'),
      Country(code: 'IN', name: 'India', nationality: 'Indian', flagEmoji: '🇮🇳'),
    ];
    _isInitialized = true;
    appLogger.w('Using fallback country data');
  }

  /// Convert country code to flag emoji
  String? _getFlagEmoji(String countryCode) {
    if (countryCode.length != 2) return null;

    // Convert each character to a regional indicator symbol letter
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Returns a list of all countries.
  Future<List<Country>> getCountries() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _countries;
  }

  /// Searches for countries based on a query string.
  /// The search is case-insensitive and matches against name, code, and nationality.
  Future<List<Country>> searchCountries(String query) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (query.isEmpty) {
      return _countries;
    }

    final lowercaseQuery = query.toLowerCase();
    return _countries.where((country) {
      return country.name.toLowerCase().contains(lowercaseQuery) ||
          country.code.toLowerCase().contains(lowercaseQuery) ||
          (country.nationality?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Returns a country by its code.
  Future<Country?> getCountryByCode(String code) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return _countries.firstWhere((country) => country.code == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }
}
