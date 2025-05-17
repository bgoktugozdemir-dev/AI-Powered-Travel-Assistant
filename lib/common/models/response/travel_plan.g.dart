// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelPlan _$TravelPlanFromJson(Map<String, dynamic> json) => TravelPlan(
  date: DateTime.parse(json['date'] as String),
  events:
      (json['events'] as List<dynamic>)
          .map((e) => TravelEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
);

TravelEvent _$TravelEventFromJson(Map<String, dynamic> json) => TravelEvent(
  name: json['name'] as String,
  time: json['time'] as String,
  location: json['location'] as String,
  description: json['description'] as String,
  requirements: json['requirements'] as String?,
);
