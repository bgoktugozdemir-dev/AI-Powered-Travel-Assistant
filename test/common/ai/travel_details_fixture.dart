import 'dart:convert';

import 'package:travel_assistant/common/models/response/travel_details.dart';

Map<String, Object?> _flight() => {
  'airline': 'TK',
  'departure_airport': 'IST',
  'arrival_airport': 'JFK',
  'flight_number': 'TK111',
  'departure_time': '2026-07-01T08:00:00Z',
  'arrival_time': '2026-07-01T14:00:00Z',
  'duration': 600,
  'price': 900.0,
  'currency': 'USD',
  'stops': 0,
  'layover_details': <Object?>[],
  'more_information': 'info',
};

Map<String, Object?> _flightOption() => {
  'departure': _flight(),
  'arrival': _flight(),
  'booking_url': 'https://example.com',
};

/// A valid `TravelDetails` JSON object used across AI pass tests.
Map<String, Object?> travelDetailsFixtureJson() => {
  'city': {
    'name': 'New York',
    'country': 'United States',
    'crowd_level': 3,
    'time': null,
    'weather': [
      {'date': '2026-07-01', 'weather': 'Sunny', 'temperature': 28.0},
    ],
  },
  'required_documents': {
    'type': 'passport',
    'message': 'Passport required',
    'steps': null,
    'more_information': null,
  },
  'currency': {
    'code': 'USD',
    'name': 'US Dollar',
    'departure_currency_code': 'TRY',
    'exchange_rate': 39.0,
    'departure_average_living_cost_per_day': 70.0,
    'arrival_average_living_cost_per_day': 160.0,
  },
  'flight_options': {
    'cheapest': _flightOption(),
    'comfortable': _flightOption(),
  },
  'tax_information': {
    'has_tax_free_options': true,
    'tax_rate': 8.0,
    'refundable_tax_rate': 5.0,
    'tax_refund_information': 'Bring receipts',
  },
  'spots': [
    {'place': 'Times Square', 'description': 'Visit', 'requirements': null},
  ],
  'travel_plan': [
    {
      'date': '2026-07-02T00:00:00.000Z',
      'events': [
        {
          'name': 'Walk',
          'time': '10:00',
          'location': 'Manhattan',
          'description': 'Walk tour',
          'requirements': null,
        },
      ],
    },
  ],
  'recommendations': ['Use metro'],
};

/// [travelDetailsFixtureJson] encoded as the text a model would return.
String travelDetailsFixtureText() => jsonEncode(travelDetailsFixtureJson());

/// A parsed `TravelDetails` for tests.
TravelDetails travelDetailsFixture() =>
    TravelDetails.fromJson(travelDetailsFixtureJson());
