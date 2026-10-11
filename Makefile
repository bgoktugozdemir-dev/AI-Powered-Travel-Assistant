build_web:
	flutter clean
	flutter pub get
	flutter build web --release --source-maps --dart-define-from-file=env/secrets.json
	flutter pub run sentry_dart_plugin