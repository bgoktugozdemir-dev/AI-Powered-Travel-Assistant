import 'package:dio/dio.dart'; // Required for DioError
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';

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
    if (query.length < 2) {
      return []; // Don't search for less than 2 characters, as per previous BLoC logic
    }
    try {
      final response = await _apiService.searchAirports(_datasetId, query, rows: 15);
      
      if (response.records == null) {
        return [];
      }

      final List<Airport> airports = [];
      for (var record in response.records!) {
        final fields = record.fields;
        if (fields != null && fields.iataCode != null && fields.name != null && fields.country != null) {
          // Basic validation: Ensure essential fields are not empty
          if (fields.iataCode!.isNotEmpty && fields.name!.isNotEmpty && fields.country!.isNotEmpty) {
             airports.add(Airport(
              iataCode: fields.iataCode!,
              name: fields.name!,
              country: fields.country!,
            ));
          }
        }
      }
      return airports;
    } on DioException catch (e) {
      // Handle Dio specific errors (network, timeout, etc.)
      // Log the error or transform it into a domain-specific error
      print('AirportRepository DioError: $e');
      throw Exception('Failed to fetch airports (Network Error): ${e.message}'); // Or a custom error type
    } catch (e) {
      // Handle other errors (parsing, etc.)
      print('AirportRepository Error: $e');
      throw Exception('Failed to fetch airports (Unknown Error): $e'); // Or a custom error type
    }
  }
} 