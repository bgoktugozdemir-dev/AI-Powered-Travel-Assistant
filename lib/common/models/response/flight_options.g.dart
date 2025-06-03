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
    );

FlightOption _$FlightOptionFromJson(Map<String, dynamic> json) => FlightOption(
  departure: Flight.fromJson(json['departure'] as Map<String, dynamic>),
  arrival: Flight.fromJson(json['arrival'] as Map<String, dynamic>),
  bookingUrl: json['booking_url'] as String,
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
  layoverDetails:
      (json['layover_details'] as List<dynamic>)
          .map((e) => LayoverDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
  moreInformation: json['more_information'] as String,
);

LayoverDetail _$LayoverDetailFromJson(Map<String, dynamic> json) =>
    LayoverDetail(
      airport: json['airport'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
    );
