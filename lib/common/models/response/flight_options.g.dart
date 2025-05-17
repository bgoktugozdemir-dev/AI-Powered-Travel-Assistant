// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlightOptions _$FlightOptionsFromJson(Map<String, dynamic> json) =>
    FlightOptions(
      cheapest: FlightOption.fromJson(json['cheapest'] as Map<String, dynamic>),
      comfortable: FlightOption.fromJson(
        json['comfortable'] as Map<String, dynamic>,
      ),
      recommended:
          json['recommended'] == null
              ? null
              : FlightOption.fromJson(
                json['recommended'] as Map<String, dynamic>,
              ),
    );

FlightOption _$FlightOptionFromJson(Map<String, dynamic> json) => FlightOption(
  departure: Flight.fromJson(json['departure'] as Map<String, dynamic>),
  arrival: Flight.fromJson(json['arrival'] as Map<String, dynamic>),
);

Flight _$FlightFromJson(Map<String, dynamic> json) => Flight(
  airline: json['airline'] as String,
  departureAirport: json['departure_airport'] as String,
  arrivalAirport: json['arrival_airport'] as String,
  flightNumber: json['flight_number'] as String,
  departureTime: DateTime.parse(json['departure_time'] as String),
  arrivalTime: DateTime.parse(json['arrival_time'] as String),
  duration: Flight._durationFromJson((json['duration'] as num).toInt()),
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  stops: (json['stops'] as num).toInt(),
  stopDurations: Flight._durationListFromJson(
    json['stop_durations'] as List<int>?,
  ),
  layovers: (json['layovers'] as num).toInt(),
  layoverDurations: Flight._durationListFromJson(
    json['layover_durations'] as List<int>?,
  ),
  moreInformation: json['more_information'] as String,
);
