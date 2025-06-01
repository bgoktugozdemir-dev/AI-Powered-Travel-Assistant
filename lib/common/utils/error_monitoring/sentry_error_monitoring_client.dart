import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

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
}

class SentryErrorMonitoringClient {
  Future<void> init({
    AppRunner? appRunner,
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
            ..environment = environment
            ..sampleRate = sampleRate ?? _Constants.sampleRate
            ..tracesSampleRate = tracesSampleRate ?? _Constants.tracesSampleRate
            ..profilesSampleRate = profilesSampleRate ?? _Constants.profilesSampleRate
            // By this code, 3rd party code will be collapsed and greyed out
            // when viewing stack traces on the Sentry dashboard
            ..considerInAppFramesByDefault = considerInAppFramesByDefault ?? _Constants.considerInAppFramesByDefault
            ..addInAppInclude('cluedo_notepad')
            //! [attachScreenshot] and [attachViewHierarchy] are expensive and should be enabled only if needed
            // Attach a screenshot to the event
            ..attachScreenshot = attachScreenshot ?? _Constants.attachScreenshot
            // Attach the view hierarchy to the event
            ..attachViewHierarchy = attachViewHierarchy ?? _Constants.attachViewHierarchy
            // Use the [beforeSend] callback to filter which events are sent
            ..beforeSend = (event, hint) async {
              // Don't send event if [sendToSentry] is false or it is a debug build
              final shouldSend = sendToSentry ?? !debug;
              if (!shouldSend) {
                return null;
              }

              // For all other events, return the event as is
              return event;
            };
        },
        appRunner: appRunner,
      );
    } catch (e, stackTrace) {
      // Log the error locally since Sentry isn't initialized yet
      appLogger.e('Failed to initialize Sentry: $e', stackTrace: stackTrace);

      if (debug) {
        rethrow;
      }
      // Return normally in production to avoid crashing the app
      return Future.value();
    }
  }
}
