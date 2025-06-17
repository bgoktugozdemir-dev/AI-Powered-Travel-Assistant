import 'package:dio/dio.dart'; // Required for DioError
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

/// Repository for fetching airport data.
class AirportRepository {
  final AirportApiService _apiService;
  final ErrorMonitoringFacade _errorMonitoringFacade;
  final String _datasetId = 'airports-code@public'; // The dataset ID for Opendatasoft

  /// Creates an [AirportRepository].
  ///
  /// Requires an [AirportApiService] instance.
  AirportRepository({
    required AirportApiService apiService,
    required ErrorMonitoringFacade errorMonitoringFacade,
  }) : _apiService = apiService,
       _errorMonitoringFacade = errorMonitoringFacade;

  /// Searches for airports using the provided [query].
  ///
  /// Returns a list of [Airport] models.
  /// Throws an exception if the API call fails or data cannot be parsed.
  Future<List<Airport>> searchAirports(String query) async {
    if (query.length < 3) {
      return [];
    }
    try {
      final response = await _apiService.searchAirports(
        _datasetId,
        query,
        rows: 15,
      );

      // Log the raw records count if records exist
      if (response.records == null) {
        _errorMonitoringFacade.reportError(
          'API returned null for records.',
          stackTrace: StackTrace.current,
          context: {
            'query': query,
            'response': response,
          },
        );
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
            _errorMonitoringFacade.reportError(
              'Skipping record due to empty field(s).',
              stackTrace: StackTrace.current,
              context: {
                'iataCode': fields.iataCode,
                'name': fields.name,
                'countryCode': fields.countryCode,
                'countryName': fields.countryName,
                'cityName': fields.cityName,
              },
            );
          }
        } else {
          _errorMonitoringFacade.reportError(
            'Skipping record due to null field(s).',
            stackTrace: StackTrace.current,
            context: {
              'fields': fields,
            },
          );
        }
      }
      return airports;
    } on DioException catch (e, stackTrace) {
      _errorMonitoringFacade.reportError(
        'AirportRepository DioError',
        stackTrace: stackTrace,
        context: {
          'query': query,
          'error': e,
        },
      );
      throw Exception('Failed to fetch airports (Network Error): ${e.message}');
    } catch (e, stackTrace) {
      _errorMonitoringFacade.reportError(
        'AirportRepository Error',
        stackTrace: stackTrace,
        context: {
          'query': query,
          'error': e,
        },
      );
      throw Exception('Failed to fetch airports (Unknown Error): $e');
    }
  }
}
