// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Currency _$CurrencyFromJson(Map<String, dynamic> json) => Currency(
  code: json['code'] as String,
  name: json['name'] as String,
  exchangeRate: (json['exchange_rate'] as num).toDouble(),
  departureAverageLivingCostPerDay:
      (json['departure_average_living_cost_per_day'] as num).toDouble(),
  arrivalAverageLivingCostPerDay:
      (json['arrival_average_living_cost_per_day'] as num).toDouble(),
);
