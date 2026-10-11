# Builds the web app with source maps, uploads them to Sentry and then deletes
# them from build/web: they expose the source code and must not be deployed.
build_web:
	flutter clean
	flutter pub get
	flutter build web --release --source-maps --dart-define-from-file=env/secrets.json
	flutter pub run sentry_dart_plugin
	find build/web -name '*.map' -type f -delete