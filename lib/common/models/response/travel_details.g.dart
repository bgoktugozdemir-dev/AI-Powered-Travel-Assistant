// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelDetails _$TravelDetailsFromJson(Map<String, dynamic> json) =>
    TravelDetails(
      city: City.fromJson(json['city'] as Map<String, dynamic>),
      requiredDocuments: RequiredDocuments.fromJson(
        json['required_documents'] as Map<String, dynamic>,
      ),
      currency: Currency.fromJson(json['currency'] as Map<String, dynamic>),
      flightOptions: FlightOptions.fromJson(
        json['flight_options'] as Map<String, dynamic>,
      ),
      taxInformation: TaxInformation.fromJson(
        json['tax_information'] as Map<String, dynamic>,
      ),
      spots:
          (json['spots'] as List<dynamic>)
              .map((e) => TravelSpot.fromJson(e as Map<String, dynamic>))
              .toList(),
      travelPlan:
          (json['travel_plan'] as List<dynamic>)
              .map((e) => TravelPlan.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );
