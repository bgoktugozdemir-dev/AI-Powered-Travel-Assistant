.PHONY: build_web deploy_web

# Builds the web app with source maps, uploads them to Sentry and then deletes
# them from build/web: they expose the source code and must not be deployed.
# Needs SENTRY_AUTH_TOKEN in the environment (the pubspec does not hold it):
#   SENTRY_AUTH_TOKEN=... make build_web
build_web:
	flutter clean
	flutter pub get
	flutter build web --release --source-maps --dart-define-from-file=env/secrets.json
	dart run sentry_dart_plugin
	find build/web -name '*.map' -type f -delete

# Manual deploy to Firebase Hosting (project in .firebaserc). Releases are
# normally deployed by .github/workflows/deploy.yml; this needs `firebase login`.
deploy_web: build_web
	firebase deploy --only hosting
