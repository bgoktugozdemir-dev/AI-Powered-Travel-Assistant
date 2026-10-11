import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/utils/helpers/parser_utils.dart';

void main() {
  group('ParserUtils regression', () {
    test('extracts JSON from markdown code fence', () {
      const text = '''
Here is the response:
```json
{"city":{"name":"Amsterdam"}}
```
''';

      final jsonText = ParserUtils.extractJsonFromText(text);

      expect(jsonText, '{"city":{"name":"Amsterdam"}}');
    });

    test('extracts direct JSON from surrounding text', () {
      const text = 'Use this payload: {"city":{"name":"Amsterdam"}} Thanks.';

      final jsonText = ParserUtils.extractJsonFromText(text);

      expect(jsonText, '{"city":{"name":"Amsterdam"}}');
    });

    test('throws FormatException when JSON is missing', () {
      expect(
        () => ParserUtils.extractJsonFromText('No JSON here.'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when decoded JSON is not an object', () {
      expect(
        () => ParserUtils.parseTravelDetailsOrThrow('[1, 2, 3]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses minimum valid TravelDetails JSON', () {
      const jsonText = '''
{
  "city": {
    "name": "Amsterdam",
    "country": "Netherlands",
    "crowd_level": 5,
    "time": null,
    "weather": [
      { "date": "2026-06-22", "weather": "Sunny", "temperature": 20.0 }
    ]
  },
  "required_documents": {
    "type": "visa",
    "message": "Visa required",
    "steps": null,
    "more_information": null
  },
  "currency": {
    "code": "EUR",
    "name": "Euro",
    "exchange_rate": 35.0,
    "arrival_average_living_cost_per_day": 130.0,
    "departure_average_living_cost_per_day": null,
    "departure_currency_code": "TRY"
  },
  "flight_options": {
    "cheapest": {
      "departure": {
        "airline": "TK",
        "departure_airport": "IST",
        "arrival_airport": "AMS",
        "flight_number": "TK123",
        "departure_time": "2026-06-22T08:00:00Z",
        "arrival_time": "2026-06-22T12:00:00Z",
        "duration": 240,
        "price": 250.0,
        "currency": "EUR",
        "stops": 0,
        "layover_details": [],
        "more_information": "N/A"
      },
      "arrival": {
        "airline": "TK",
        "departure_airport": "AMS",
        "arrival_airport": "IST",
        "flight_number": "TK124",
        "departure_time": "2026-06-28T10:00:00Z",
        "arrival_time": "2026-06-28T14:00:00Z",
        "duration": 240,
        "price": 260.0,
        "currency": "EUR",
        "stops": 0,
        "layover_details": [],
        "more_information": "N/A"
      },
      "booking_url": "https://example.com"
    },
    "comfortable": {
      "departure": {
        "airline": "TK",
        "departure_airport": "IST",
        "arrival_airport": "AMS",
        "flight_number": "TK125",
        "departure_time": "2026-06-22T09:00:00Z",
        "arrival_time": "2026-06-22T13:00:00Z",
        "duration": 240,
        "price": 300.0,
        "currency": "EUR",
        "stops": 0,
        "layover_details": [],
        "more_information": "N/A"
      },
      "arrival": {
        "airline": "TK",
        "departure_airport": "AMS",
        "arrival_airport": "IST",
        "flight_number": "TK126",
        "departure_time": "2026-06-28T11:00:00Z",
        "arrival_time": "2026-06-28T15:00:00Z",
        "duration": 240,
        "price": 310.0,
        "currency": "EUR",
        "stops": 0,
        "layover_details": [],
        "more_information": "N/A"
      },
      "booking_url": "https://example.com"
    }
  },
  "tax_information": {
    "has_tax_free_options": false,
    "tax_rate": 0.0,
    "refundable_tax_rate": 0.0,
    "tax_refund_information": null
  },
  "spots": [
    { "place": "Canal Belt", "description": "Great views", "requirements": null }
  ],
  "travel_plan": [
    {
      "date": "2026-06-22T00:00:00Z",
      "events": [
        {
          "name": "Arrival",
          "time": "Morning",
          "location": "Amsterdam",
          "description": "Arrive and check in",
          "requirements": null
        }
      ]
    }
  ],
  "recommendations": ["Use public transport"]
}
''';
      final parsed = ParserUtils.parseTravelDetails(jsonText);
      expect(parsed, isNotNull);
    });

    test('rejects uppercase required_documents.type enum variant', () {
      const jsonText = '''
{
  "city": { "name": "A", "country": "B", "crowd_level": 1, "time": null, "weather": [] },
  "required_documents": { "type": "Visa", "message": "x", "steps": null, "more_information": null },
  "currency": {
    "code": "EUR",
    "name": "Euro",
    "exchange_rate": 1.0,
    "arrival_average_living_cost_per_day": 1.0,
    "departure_average_living_cost_per_day": null,
    "departure_currency_code": "TRY"
  },
  "flight_options": {
    "cheapest": {
      "departure": {
        "airline": "x", "departure_airport": "x", "arrival_airport": "x",
        "flight_number": "x", "departure_time": "2026-01-01T00:00:00Z",
        "arrival_time": "2026-01-01T01:00:00Z", "duration": 60, "price": 1.0,
        "currency": "EUR", "stops": 0, "layover_details": [], "more_information": "x"
      },
      "arrival": {
        "airline": "x", "departure_airport": "x", "arrival_airport": "x",
        "flight_number": "x", "departure_time": "2026-01-02T00:00:00Z",
        "arrival_time": "2026-01-02T01:00:00Z", "duration": 60, "price": 1.0,
        "currency": "EUR", "stops": 0, "layover_details": [], "more_information": "x"
      },
      "booking_url": "https://example.com"
    },
    "comfortable": {
      "departure": {
        "airline": "x", "departure_airport": "x", "arrival_airport": "x",
        "flight_number": "x", "departure_time": "2026-01-01T00:00:00Z",
        "arrival_time": "2026-01-01T01:00:00Z", "duration": 60, "price": 1.0,
        "currency": "EUR", "stops": 0, "layover_details": [], "more_information": "x"
      },
      "arrival": {
        "airline": "x", "departure_airport": "x", "arrival_airport": "x",
        "flight_number": "x", "departure_time": "2026-01-02T00:00:00Z",
        "arrival_time": "2026-01-02T01:00:00Z", "duration": 60, "price": 1.0,
        "currency": "EUR", "stops": 0, "layover_details": [], "more_information": "x"
      },
      "booking_url": "https://example.com"
    }
  },
  "tax_information": { "has_tax_free_options": false, "tax_rate": 0.0, "refundable_tax_rate": 0.0, "tax_refund_information": null },
  "spots": [],
  "travel_plan": [],
  "recommendations": []
}
''';
      final parsed = ParserUtils.parseTravelDetails(jsonText);
      expect(parsed, isNull);
    });
  });
}
