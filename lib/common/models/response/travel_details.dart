import 'package:json_annotation/json_annotation.dart';
import 'package:travel_assistant/common/models/response/city.dart';
import 'package:travel_assistant/common/models/response/currency.dart';
import 'package:travel_assistant/common/models/response/flight_options.dart';
import 'package:travel_assistant/common/models/response/required_documents.dart';
import 'package:travel_assistant/common/models/response/tax_information.dart';
import 'package:travel_assistant/common/models/response/travel_plan.dart';
import 'package:travel_assistant/common/models/response/travel_spot.dart';

part 'travel_details.g.dart';

@JsonSerializable(createToJson: false)
class TravelDetails {
  const TravelDetails({
    required this.city,
    required this.requiredDocuments,
    required this.currency,
    required this.flightOptions,
    required this.taxInformation,
    required this.spots,
    required this.travelPlan,
    required this.recommendations,
  });

  factory TravelDetails.fromJson(Map<String, dynamic> json) =>
      _$TravelDetailsFromJson(json);

  @JsonKey(name: 'city')
  final City city;

  @JsonKey(name: 'required_documents')
  final RequiredDocuments requiredDocuments;

  @JsonKey(name: 'currency')
  final Currency currency;

  @JsonKey(name: 'flight_options')
  final FlightOptions flightOptions;

  @JsonKey(name: 'tax_information')
  final TaxInformation taxInformation;

  @JsonKey(name: 'spots')
  final List<TravelSpot> spots;

  @JsonKey(name: 'travel_plan')
  final List<TravelPlan> travelPlan;

  @JsonKey(name: 'recommendations')
  final List<String> recommendations;
}
