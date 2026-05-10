import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'currency.g.dart';

@JsonSerializable(createToJson: false)
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.departureCurrencyCode,
    required this.exchangeRate,
    required this.departureAverageLivingCostPerDay,
    required this.arrivalAverageLivingCostPerDay,
  });

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);

  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'departure_currency_code')
  final String? departureCurrencyCode;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'exchange_rate', defaultValue: 1)
  final double exchangeRate;

  @JsonKey(name: 'departure_average_living_cost_per_day')
  final double? departureAverageLivingCostPerDay;

  @JsonKey(name: 'arrival_average_living_cost_per_day')
  final double arrivalAverageLivingCostPerDay;

  static Schema get aiSchema => Schema.object(
    properties: {
      'code': Schema.string(),
      'name': Schema.string(),
      'exchange_rate': Schema.number(),
      'arrival_average_living_cost_per_day': Schema.number(),
      'departure_currency_code': Schema.string(nullable: true),
      'departure_average_living_cost_per_day': Schema.number(nullable: true),
    },
    optionalProperties: [
      'departure_currency_code',
      'departure_average_living_cost_per_day',
    ],
  );
}
