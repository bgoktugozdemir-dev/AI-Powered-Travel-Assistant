import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/utils/error_monitoring/remote_config_feature_flags.dart';

/// A Remote Config that fails the test when its realtime update stream is used.
class _FakeFirebaseRemoteConfig implements FirebaseRemoteConfig {
  _FakeFirebaseRemoteConfig(Map<String, String> values)
    : _values = {
        for (final entry in values.entries)
          entry.key: RemoteConfigValue(
            utf8.encode(entry.value),
            ValueSource.valueRemote,
          ),
      };

  final Map<String, RemoteConfigValue> _values;
  bool onConfigUpdatedAccessed = false;

  @override
  Map<String, RemoteConfigValue> getAll() => _values;

  @override
  Stream<RemoteConfigUpdate> get onConfigUpdated {
    onConfigUpdatedAccessed = true;
    throw StateError('The realtime update stream must not be used.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RemoteConfigFeatureFlags.booleanFlags', () {
    test('keeps booleans, in any case, and the numbers 1 and 0', () {
      final flags = RemoteConfigFeatureFlags.booleanFlags({
        'a': 'true',
        'b': 'FALSE',
        'c': '1',
        'd': '0',
        'e': 'True',
      });

      expect(flags, {'a': true, 'b': false, 'c': true, 'd': false, 'e': true});
    });

    test('ignores values that are not booleans', () {
      final flags = RemoteConfigFeatureFlags.booleanFlags({
        'token': 'abc123',
        'count': '2',
        'empty': '',
        'json': '{"a": true}',
      });

      expect(flags, isEmpty);
    });
  });

  group('RemoteConfigFeatureFlags.report', () {
    test('reports each boolean value once, with the firebase prefix', () async {
      final remoteConfig = _FakeFirebaseRemoteConfig({
        'show_city_card': 'true',
        'cache_weather_data': 'false',
        'sentry_dsn': 'https://example.invalid/1',
      });
      final reported = <String, bool>{};

      await RemoteConfigFeatureFlags.report(
        remoteConfig,
        addFeatureFlag: (flag, value) => reported[flag] = value,
      );

      expect(reported, {
        'firebase:show_city_card': true,
        'firebase:cache_weather_data': false,
      });
    });

    test('never subscribes to the realtime update stream', () async {
      final remoteConfig = _FakeFirebaseRemoteConfig({'flag': 'true'});

      await RemoteConfigFeatureFlags.report(
        remoteConfig,
        addFeatureFlag: (flag, value) {},
      );

      expect(remoteConfig.onConfigUpdatedAccessed, isFalse);
    });
  });
}
