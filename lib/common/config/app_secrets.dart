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

  /// Validates required secrets at startup.
  static void validate() {
    if (freeCurrencyApiKey.isEmpty) {
      throw Exception(
        'AppSecrets.freeCurrencyApiKey is empty. '
        'Run flutter with --dart-define-from-file=env/secrets.json',
      );
    }
  }
}
