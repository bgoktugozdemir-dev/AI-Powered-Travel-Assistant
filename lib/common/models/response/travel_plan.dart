import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'travel_plan.g.dart';

abstract class _Constants {
  static const String dateOnlyPattern = r'^\d{4}-\d{2}-\d{2}$';
  static const String timezoneSuffixPattern = r'(Z|[+-]\d{2}:\d{2})$';
}

@JsonSerializable(createToJson: false)
class TravelPlan {
  const TravelPlan({required this.date, required this.events});

  factory TravelPlan.fromJson(Map<String, dynamic> json) =>
      _$TravelPlanFromJson(json);

  @JsonKey(name: 'date', fromJson: _dateFromJson)
  final DateTime date;

  @JsonKey(name: 'events')
  final List<TravelEvent> events;

  static Schema get aiSchema => Schema.object(
    properties: {
      'date': Schema.string(
        description:
            'Travel day as YYYY-MM-DD or ISO 8601 datetime. '
            'Date-only values are normalized to 00:00:00Z. '
            'Datetime values must include timezone/offset.',
      ),
      'events': Schema.array(items: TravelEvent.aiSchema),
    },
  );

  static DateTime _dateFromJson(String value) {
    final dateOnlyPattern = RegExp(_Constants.dateOnlyPattern);
    if (dateOnlyPattern.hasMatch(value)) {
      return DateTime.parse('${value}T00:00:00Z').toUtc();
    }

    final timezoneSuffixPattern = RegExp(_Constants.timezoneSuffixPattern);
    if (!timezoneSuffixPattern.hasMatch(value)) {
      throw FormatException(
        'TravelPlan.date datetime values must include timezone/offset: $value',
      );
    }

    final parsed = DateTime.parse(value);
    return parsed.isUtc ? parsed : parsed.toUtc();
  }
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
