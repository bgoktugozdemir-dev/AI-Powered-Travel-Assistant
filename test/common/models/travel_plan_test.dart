import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/models/response/travel_plan.dart';

void main() {
  group('TravelPlan.date parsing', () {
    test('normalizes date-only values to midnight UTC', () {
      final travelPlan = TravelPlan.fromJson({
        'date': '2026-06-22',
        'events': [],
      });

      expect(travelPlan.date, DateTime.utc(2026, 6, 22));
      expect(travelPlan.date.isUtc, isTrue);
    });

    test('keeps Z datetime values in UTC', () {
      final travelPlan = TravelPlan.fromJson({
        'date': '2026-06-22T10:30:00Z',
        'events': [],
      });

      expect(travelPlan.date, DateTime.utc(2026, 6, 22, 10, 30));
      expect(travelPlan.date.isUtc, isTrue);
    });

    test('converts offset datetime values to UTC', () {
      final travelPlan = TravelPlan.fromJson({
        'date': '2026-06-22T10:30:00+03:00',
        'events': [],
      });

      expect(travelPlan.date, DateTime.utc(2026, 6, 22, 7, 30));
      expect(travelPlan.date.isUtc, isTrue);
    });

    test('rejects timezone-less datetime values', () {
      expect(
        () => TravelPlan.fromJson({
          'date': '2026-06-22T10:30:00',
          'events': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
