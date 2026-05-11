import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'travel_plan.g.dart';

@JsonSerializable(createToJson: false)
class TravelPlan {
  const TravelPlan({required this.date, required this.events});

  factory TravelPlan.fromJson(Map<String, dynamic> json) =>
      _$TravelPlanFromJson(json);

  @JsonKey(name: 'date')
  final DateTime date;

  @JsonKey(name: 'events')
  final List<TravelEvent> events;

  static Schema get aiSchema => Schema.object(
    properties: {
      'date': Schema.string(
        description: 'Travel day in ISO 8601 date or datetime format.',
      ),
      'events': Schema.array(items: TravelEvent.aiSchema),
    },
  );
}

@JsonSerializable(createToJson: false)
class TravelEvent {
  const TravelEvent({
    required this.name,
    required this.time,
    required this.location,
    required this.description,
    required this.requirements,
  });

  factory TravelEvent.fromJson(Map<String, dynamic> json) =>
      _$TravelEventFromJson(json);

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'time')
  final String time;

  @JsonKey(name: 'location')
  final String location;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'requirements')
  final String? requirements;

  static Schema get aiSchema => Schema.object(
    properties: {
      'name': Schema.string(),
      'time': Schema.string(),
      'location': Schema.string(),
      'description': Schema.string(),
      'requirements': Schema.string(nullable: true),
    },
    optionalProperties: ['requirements'],
  );
}
