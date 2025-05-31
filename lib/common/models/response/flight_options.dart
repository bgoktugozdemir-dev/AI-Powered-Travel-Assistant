import 'package:json_annotation/json_annotation.dart';

part 'flight_options.g.dart';

@JsonSerializable(createToJson: false)
class FlightOptions {
  const FlightOptions({
    required this.cheapest,
    required this.comfortable,
  });

  factory FlightOptions.fromJson(Map<String, dynamic> json) => _$FlightOptionsFromJson(json);

  @JsonKey(name: 'cheapest')
  final FlightOption cheapest;

  @JsonKey(name: 'comfortable')
  final FlightOption comfortable;
}

@JsonSerializable(createToJson: false)
class FlightOption {
  const FlightOption({
    required this.departure,
    required this.arrival,
    required this.bookingUrl,
  });

  factory FlightOption.fromJson(Map<String, dynamic> json) => _$FlightOptionFromJson(json);

  @JsonKey(name: 'departure')
  final Flight departure;

  @JsonKey(name: 'arrival')
  final Flight arrival;

  @JsonKey(name: 'booking_url')
  final String bookingUrl;
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
    required this.stopDurations,
    required this.layovers,
    required this.layoverDurations,
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

  @JsonKey(name: 'stop_durations', fromJson: _durationListFromJson)
  final List<Duration>? stopDurations;

  @JsonKey(name: 'layovers')
  final int layovers;

  @JsonKey(name: 'layover_durations', fromJson: _durationListFromJson)
  final List<Duration>? layoverDurations;

  @JsonKey(name: 'more_information')
  final String moreInformation;

  static Duration _durationFromJson(int duration) => Duration(minutes: duration);

  static List<Duration>? _durationListFromJson(List<dynamic>? durations) =>
      durations?.map((duration) => _durationFromJson(int.parse(duration.toString()))).toList();
}
