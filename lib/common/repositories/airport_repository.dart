import 'package:dio/dio.dart'; // Required for DioError
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/utils/logger.dart'; // Import appLogger

/// Repository for fetching airport data.
class AirportRepository {
  final AirportApiService _apiService;
  final String _datasetId = 'airports-code@public'; // The dataset ID for Opendatasoft

  /// Creates an [AirportRepository].
  ///
  /// Requires an [AirportApiService] instance.
  AirportRepository({required AirportApiService apiService}) : _apiService = apiService;

  /// Searches for airports using the provided [query].
  ///
  /// Returns a list of [Airport] models.
  /// Throws an exception if the API call fails or data cannot be parsed.
  Future<List<Airport>> searchAirports(String query) async {
    if (query.length < 3) {
      // Align with BLoC logic
      appLogger.i("Airport search query too short: '$query'. Returning empty list.");
      return [];
    }
    try {
      appLogger.d("Searching airports with query: '$query'");
      final response = await _apiService.searchAirports(_datasetId, query, rows: 15);

      // Log the raw records count if records exist
      if (response.records != null) {
        appLogger.i("API returned ${response.records!.length} records.");
      } else {
        appLogger.w("API returned null for records.");
        return [];
      }

      final List<Airport> airports = [];
      for (var record in response.records!) {
        final fields = record.fields;
        if (fields != null) {
          if (fields.iataCode.isNotEmpty &&
              fields.name.isNotEmpty &&
              fields.countryCode.isNotEmpty &&
              fields.countryName.isNotEmpty &&
              fields.cityName.isNotEmpty) {
            airports.add(
              Airport(
                iataCode: fields.iataCode,
                name: fields.name,
                countryCode: fields.countryCode,
                countryName: fields.countryName,
                cityName: fields.cityName,
              ),
            );
          } else {
            appLogger.w(
              "Skipping record due to empty field(s): IATA='${fields.iataCode}', Name='${fields.name}', Country='${fields.countryName}'",
            );
          }
        } else {
          appLogger.w(
            "Skipping record due to null field(s): IATA='${fields?.iataCode}', Name='${fields?.name}', Country='${fields?.countryName}'",
          );
        }
      }
      appLogger.i("Successfully parsed ${airports.length} airport(s).");
      return airports;
    } on DioException catch (e) {
      appLogger.e('AirportRepository DioError', error: e, stackTrace: e.stackTrace);
      throw Exception('Failed to fetch airports (Network Error): ${e.message}');
    } catch (e, stackTrace) {
      appLogger.e('AirportRepository Error', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch airports (Unknown Error): $e');
    }
  }
}
