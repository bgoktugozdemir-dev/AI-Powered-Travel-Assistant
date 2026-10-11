// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_firebase_remote_config/sentry_firebase_remote_config.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_report.dart';

abstract class _Constants {
  /// Set sampleRate to 1.0 to capture 100% of transactions for error monitoring.
  /// If set to 0.1 only 10% of events will be sent. Events are picked randomly.
  static const double sampleRate = 1.0;

  /// Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
  /// We recommend adjusting this value in production.
  static const double tracesSampleRate = 1.0;

  /// The sampling rate for profiling is relative to tracesSampleRate
  /// Setting to 1.0 will profile 100% of sampled transactions:
  static const double profilesSampleRate = 1.0;

  /// By default, Sentry considers all frames in the app to be in-app.
  /// This means that frames from the Flutter framework and packages will be collapsed
  /// and greyed out when viewing stack traces on the Sentry dashboard.
  static bool considerInAppFramesByDefault = true;

  /// Attach a screenshot to the event
  ///
  /// This is expensive and should be enabled only if needed.
  /// The `attachScreenshot` options are resource-intensive and
  /// may impact performance and storage, especially in production environments
  static bool attachScreenshot = false;

  /// Attach the view hierarchy to the event
  ///
  /// This is expensive and should be enabled only if needed.
  /// The `attachViewHierarchy` options are resource-intensive and
  /// may impact performance and storage, especially in production environments
  static bool attachViewHierarchy = false;

  /// Exact message of the reCAPTCHA error that is dropped in [filterEvent].
  static const String recaptchaAlreadyRendered =
      'reCAPTCHA has already been rendered in this element';

  /// Tag holding the human readable message of a report.
  static const String reportMessageTag = 'report_message';

  /// Sentry truncates tag values at 200 characters.
  static const int maxTagLength = 200;
}

class SentryErrorMonitoringClient implements ErrorMonitoringClient {
  SentryErrorMonitoringClient() : _enabled = true;

  bool _enabled;

  /// Initializes Sentry with the provided configuration.
  @override
  Future<void> init({
    AppRunner? appRunner,
    FirebaseRemoteConfig? firebaseRemoteConfig,
    String? dsn,
    bool debug = false,
    bool? sendToSentry,
    String? environment,
    double? sampleRate,
    double? tracesSampleRate,
    double? profilesSampleRate,
    bool? skipReporting,
    bool? considerInAppFramesByDefault,
    bool? attachScreenshot,
    bool? attachViewHierarchy,
  }) async {
    if (skipReporting == true) {
      return Future.value();
    }

    if (dsn == null) {
      throw ArgumentError('Sentry DSN is required');
    }

    try {
      await SentryFlutter.init(
        (options) {
          options
            ..dsn = dsn
            ..debug = debug
            ..useFlutterBreadcrumbTracking()
            ..environment = environment
            ..sampleRate = sampleRate ?? _Constants.sampleRate
            ..tracesSampleRate = tracesSampleRate ?? _Constants.tracesSampleRate
            ..profilesSampleRate = profilesSampleRate ?? _Constants.profilesSampleRate
            // By this code, 3rd party code will be collapsed and greyed out
            // when viewing stack traces on the Sentry dashboard
            ..considerInAppFramesByDefault = considerInAppFramesByDefault ?? _Constants.considerInAppFramesByDefault
            ..addInAppInclude('travel_assistant')
            //! [attachScreenshot] and [attachViewHierarchy] are expensive and should be enabled only if needed
            // Attach a screenshot to the event
            ..attachScreenshot = attachScreenshot ?? _Constants.attachScreenshot
            // Attach the view hierarchy to the event
            ..attachViewHierarchy = attachViewHierarchy ?? _Constants.attachViewHierarchy
            // Attach HTTP breadcrumbs to the event
            ..recordHttpBreadcrumbs = !debug
            // Use the [beforeSend] callback to filter which events are sent
            ..beforeSend = (event, hint) async {
              return filterEvent(
                event,
                // Don't send events if [sendToSentry] is false or it is a debug build
                shouldSend: sendToSentry ?? !debug,
              );
            }
            ..beforeCaptureScreenshot = (event, hint, debounce) async {
              // If debounce is active, skip capturing
              if (debounce || sendToSentry == false || debug) {
                return false;
              }
              // Capture if it's a fatal event
              return event.level == SentryLevel.fatal;
            };

          // Add Firebase Remote Config integration if available
          if (firebaseRemoteConfig != null) {
            options.addIntegration(
              SentryFirebaseRemoteConfigIntegration(
                firebaseRemoteConfig: firebaseRemoteConfig,
              ),
            );
          }
        },
        appRunner: appRunner,
      );
    } catch (e) {
      if (debug) {
        rethrow;
      }
      // Return normally in production to avoid crashing the app
      return Future.value();
    }
  }

  @override
  void setErrorMonitoringEnabled(bool enabled) {
    _enabled = enabled;
    // Note: Sentry doesn't support runtime enabling/disabling in this version
    // This would need to be handled at initialization time
  }

  @override
  Future<void> setUser(String userId) async {
    if (!_enabled) return;

    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId));
    });
  }

  /// Decides whether [event] is sent. Returns `null` to drop it.
  @visibleForTesting
  static SentryEvent? filterEvent(
    SentryEvent event, {
    required bool shouldSend,
  }) {
    if (!shouldSend) {
      return null;
    }

    final exceptions = event.exceptions;
    if (exceptions != null &&
        exceptions.any(
          (exception) =>
              exception.value?.contains(_Constants.recaptchaAlreadyRendered) ??
              false,
        )) {
      // Thrown by the Firebase App Check reCAPTCHA widget when a link-preview
      // crawler (e.g. Meta's) executes the page. Not actionable and never
      // seen from real users, so don't let it create issues.
      return null;
    }

    // For all other events, return the event as is
    return event;
  }

  @override
  Future<void> reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_enabled) return;

    await _capture(
      error,
      level: SentryLevel.error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  Future<void> reportException(
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_enabled) return;

    await _capture(
      exception,
      level: SentryLevel.fatal,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Captures the real exception (see [resolveErrorReport]) so Sentry shows
  /// its actual type and message, and keeps the human message as a tag and
  /// context.
  Future<void> _capture(
    Object error, {
    required SentryLevel level,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final report = resolveErrorReport(error, context: context);

    await Sentry.captureException(
      report.error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.level = level;
        if (report.message case final message?) {
          scope.setTag(
            _Constants.reportMessageTag,
            message.length > _Constants.maxTagLength
                ? message.substring(0, _Constants.maxTagLength)
                : message,
          );
          scope.setContexts('report', {'message': message});
        }
        for (final entry in report.context.entries) {
          scope.setContexts(entry.key, entry.value);
        }
      },
    );
  }

  @override
  Future<void> addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) async {
    if (!_enabled) return;

    await Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> setCustomData(String key, dynamic value) async {
    if (!_enabled) return;

    await Sentry.configureScope((scope) {
      scope.setTag(key, value.toString());
    });
  }

  @override
  Future<void> setCustomContext(Map<String, dynamic> context) async {
    if (!_enabled) return;

    await Sentry.configureScope((scope) {
      for (final entry in context.entries) {
        scope.setContexts(entry.key, entry.value);
      }
    });
  }

  @override
  Future<void> captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? context,
  }) async {
    if (!_enabled) return;

    final sentryLevel = _parseSentryLevel(level);

    await Sentry.captureMessage(
      message,
      level: sentryLevel,
      withScope: (scope) {
        if (context != null) {
          for (final entry in context.entries) {
            scope.setContexts(entry.key, entry.value);
          }
        }
      },
    );
  }

  @override
  Future<void> clearUser() async {
    if (!_enabled) return;

    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  @override
  Future<void> clearCustomData() async {
    if (!_enabled) return;

    await Sentry.configureScope((scope) {
      scope.clear();
    });
  }

  SentryLevel _parseSentryLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'debug':
        return SentryLevel.debug;
      case 'info':
        return SentryLevel.info;
      case 'warning':
        return SentryLevel.warning;
      case 'error':
        return SentryLevel.error;
      case 'fatal':
        return SentryLevel.fatal;
      default:
        return SentryLevel.error;
    }
  }
}
