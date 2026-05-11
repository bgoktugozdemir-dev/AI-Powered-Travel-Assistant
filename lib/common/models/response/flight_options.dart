import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'flight_options.g.dart';

@JsonSerializable(createToJson: false)
class FlightOptions {
  const FlightOptions({
    required this.cheapest,
    required this.comfortable,
  });

  factory FlightOptions.fromJson(Map<String, dynamic> json) =>
      _$FlightOptionsFromJson(json);

  @JsonKey(name: 'cheapest')
  final FlightOption cheapest;

  @JsonKey(name: 'comfortable')
  final FlightOption comfortable;

  static Schema get aiSchema => Schema.object(
    properties: {
      'cheapest': FlightOption.aiSchema,
      'comfortable': FlightOption.aiSchema,
    },
  );
}

@JsonSerializable(createToJson: false)
class FlightOption {
  const FlightOption({
    required this.departure,
    required this.arrival,
    required this.bookingUrl,
  });

  factory FlightOption.fromJson(Map<String, dynamic> json) =>
      _$FlightOptionFromJson(json);

  @JsonKey(name: 'departure')
  final Flight departure;

  @JsonKey(name: 'arrival')
  final Flight arrival;

  @JsonKey(name: 'booking_url')
  final String bookingUrl;

  static Schema get aiSchema => Schema.object(
    properties: {
      'departure': Flight.aiSchema,
      'arrival': Flight.aiSchema,
      'booking_url': Schema.string(),
    },
  );
}

@JsonSerializable(createToJson: false)
class Flight {
  const Flight({
    required this.airline,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.stops,
    required this.layoverDetails,
    required this.moreInformation,
  });

  factory Flight.fromJson(Map<String, dynamic> json) => _$FlightFromJson(json);

  @JsonKey(name: 'airline')
  final String airline;

  @JsonKey(name: 'departure_airport')
  final String departureAirport;

  @JsonKey(name: 'arrival_airport')
  final String arrivalAirport;

  @JsonKey(name: 'flight_number')
  final String flightNumber;

  @JsonKey(name: 'departure_time')
  final DateTime departureTime;

  @JsonKey(name: 'arrival_time')
  final DateTime arrivalTime;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'duration', fromJson: _durationFromJson)
  final Duration duration;

  @JsonKey(name: 'stops')
  final int stops;

  @JsonKey(name: 'layover_details')
  final List<LayoverDetail> layoverDetails;

  @JsonKey(name: 'more_information')
  final String moreInformation;

  static Schema get aiSchema => Schema.object(
    properties: {
      'airline': Schema.string(),
      'departure_airport': Schema.string(),
      'arrival_airport': Schema.string(),
      'flight_number': Schema.string(),
      'departure_time': Schema.string(
        description: 'Departure timestamp in ISO 8601 datetime format.',
      ),
      'arrival_time': Schema.string(
        description: 'Arrival timestamp in ISO 8601 datetime format.',
      ),
      'duration': Schema.integer(
        description: 'Total flight duration in minutes.',
      ),
      'price': Schema.number(),
      'currency': Schema.string(),
      'stops': Schema.integer(),
      'layover_details': Schema.array(items: LayoverDetail.aiSchema),
      'more_information': Schema.string(),
    },
  );

  static Duration _durationFromJson(int duration) =>
      Duration(minutes: duration);
}

@JsonSerializable(createToJson: false)
class LayoverDetail {
  const LayoverDetail({
    required this.airport,
    required this.durationMinutes,
  });

  factory LayoverDetail.fromJson(Map<String, dynamic> json) =>
      _$LayoverDetailFromJson(json);

  @JsonKey(name: 'airport')
  final String airport;

  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  static Schema get aiSchema => Schema.object(
    properties: {
      'airport': Schema.string(),
      'duration_minutes': Schema.integer(),
    },
  );
}
