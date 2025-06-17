import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:travel_assistant/common/models/country.dart';

abstract class _Constants {
  static const String countryApiUrl =
      'https://raw.githubusercontent.com/Imagin-io/country-nationality-list/refs/heads/master/countries.json';
}

/// Service for providing country data.
/// Fetches country data from a remote API and provides methods to search and filter.
class CountryService {
  final Dio _dio;
  List<Country> _countries = [];
  bool _isInitialized = false;

  /// Creates a [CountryService] with an optional [Dio] instance.
  CountryService({
    required Dio dio,
  }) : _dio = dio;

  /// Initialize the service by fetching countries from the API.
  /// This should be called before using the service.
  /// Throws an exception if initialization fails.
  Future<void> initialize() async {
    if (_isInitialized) return;

    final response = await _dio.get(_Constants.countryApiUrl);
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
  /// Throws an exception if the service is not initialized.
  Future<List<Country>> getCountries() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _countries;
  }

  /// Searches for countries based on a query string.
  /// The search is case-insensitive and matches against name, code, and nationality.
  /// Throws an exception if the service is not initialized.
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
  /// Throws an exception if the service is not initialized.
  Future<Country?> getCountryByCode(String code) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return _countries.firstWhere(
        (country) => country.code == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Reset the service initialization state.
  /// Useful for retry functionality.
  void reset() {
    _isInitialized = false;
    _countries = [];
  }
}
