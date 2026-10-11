import 'package:flutter/foundation.dart' show debugPrint;

/// Compile-time secrets loaded via --dart-define-from-file.
class AppSecrets {
  const AppSecrets._();

  /// Free Currency API key.
  static String get freeCurrencyApiKey {
    return const String.fromEnvironment(
      'FREE_CURRENCY_API_KEY',
      defaultValue: '',
    );
  }

  /// Warns about missing secrets at startup.
  ///
  /// Does not throw: a missing key only disables the features that need it
  /// (e.g. live currency rates), it must not prevent the app from starting.
  static void validate() {
    if (freeCurrencyApiKey.isEmpty) {
      debugPrint(
        'AppSecrets.freeCurrencyApiKey is empty. '
        'Run flutter with --dart-define-from-file=env/secrets.json',
      );
    }
  }
}
