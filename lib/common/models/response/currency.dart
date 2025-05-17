import 'package:json_annotation/json_annotation.dart';

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

  factory Currency.fromJson(Map<String, dynamic> json) => _$CurrencyFromJson(json);

  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'departure_currency_code')
  final String departureCurrencyCode;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'exchange_rate')
  final double exchangeRate;

  @JsonKey(name: 'departure_average_living_cost_per_day')
  final double departureAverageLivingCostPerDay;

  @JsonKey(name: 'arrival_average_living_cost_per_day')
  final double arrivalAverageLivingCostPerDay;

  double get departureAverageLivingCostPerDayInArrivalCurrency => departureAverageLivingCostPerDay * exchangeRate;

  double get arrivalAverageLivingCostPerDayInDepartureCurrency => arrivalAverageLivingCostPerDay / exchangeRate;
}
