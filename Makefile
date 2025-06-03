build_web:
	flutter clean
	flutter pub get
	flutter build web --release --source-maps
	flutter pub run sentry_dart_plugin