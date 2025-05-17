import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:travel_assistant/common/models/airport.dart';

part 'airport_api_service.g.dart';

// Define a wrapper class for the API response structure
// based on Opendatasoft's typical /search/ API response.
class AirportApiResponse {
  // int? nhits;
  List<AirportRecord>? records;

  AirportApiResponse({this.records});

  factory AirportApiResponse.fromJson(Map<String, dynamic> json) {
    return AirportApiResponse(
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => AirportRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AirportRecord {
  AirportFields? fields;
  // String? recordid; // if needed

  AirportRecord({this.fields});

  factory AirportRecord.fromJson(Map<String, dynamic> json) {
    return AirportRecord(
      fields: json['fields'] != null
          ? AirportFields.fromJson(json['fields'] as Map<String, dynamic>)
          : null,
    );
  }
}

// This class should map to the fields within each record that we need for our Airport model.
// We might need to adjust field names based on the actual API response ('iata_code', 'name', 'country_code', etc.)
// For now, assuming direct mapping or slight variations.
@JsonSerializable()
class AirportFields {
  @JsonKey(name: 'iata_code') // Assuming API field name is iata_code
  String? iataCode;
  String? name; // Assuming API field name is 'name' or similar like 'airport_name'
  @JsonKey(name: 'country') // Assuming API field name is 'country' or 'country_name'
  String? country;
  // Add other fields if needed, e.g., city, coordinates

  AirportFields({this.iataCode, this.name, this.country});

  factory AirportFields.fromJson(Map<String, dynamic> json) => _$AirportFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$AirportFieldsToJson(this);
}

/// API Service for fetching airport data.
@RestApi(baseUrl: "https://data.opendatasoft.com/api/records/1.0/")
abstract class AirportApiService {
  /// Creates an [AirportApiService] instance.
  factory AirportApiService(Dio dio, {String baseUrl}) = _AirportApiService;

  /// Searches for airports based on a query string.
  /// 
  /// The [query] will be used to search against airport names, IATA codes, etc.
  /// The `dataset` parameter is fixed for this specific airport dataset.
  /// We use a wrapper [AirportApiResponse] to parse the outer structure of the API response.
  @GET("/search/")
  Future<AirportApiResponse> searchAirports(
    @Query("dataset") String datasetId, // Should be 'airports-code@public'
    @Query("q") String query,
    {@Query("rows") int rows = 10}
  );
} 