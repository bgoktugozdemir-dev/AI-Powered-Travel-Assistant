import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_assistant/common/ai/function_call_dispatcher.dart';
import 'package:travel_assistant/common/ai/template_aware_passes.dart';
import 'package:travel_assistant/common/ai/template_travel_passes.dart';
import 'package:travel_assistant/common/ai/travel_format_pass.dart';
import 'package:travel_assistant/common/ai/travel_research_pass.dart';
import 'package:travel_assistant/common/ai/travel_template_client.dart';
import 'package:travel_assistant/common/config/app_secrets.dart';
import 'package:travel_assistant/common/repositories/airport_repository.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_ai_repository.dart';
import 'package:travel_assistant/common/repositories/image_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/services/country_service.dart';
import 'package:travel_assistant/common/services/free_currency_api_service.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/services/image_to_base64_service.dart';
import 'package:travel_assistant/common/services/open_meteo_service.dart';
import 'package:travel_assistant/common/services/travel_purpose_service.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/analytics/firebase_analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/logger_analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/mixpanel_analytics_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/logger_error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/sentry_error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/uncaught_error_reporter.dart';
import 'package:travel_assistant/common/utils/network/sentry_dio_interceptor.dart';
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:travel_assistant/features/startup/ui/startup_error_app.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/travel_form_screen.dart';
import 'package:travel_assistant/firebase_options.dart';
import 'package:travel_assistant/common/theme/app_theme.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:travel_assistant/features/travel_form/error/travel_form_error.dart';
import 'package:travel_assistant/features/travel_form/ui/dialog/travel_form_error_dialog.dart';

abstract class _Constants {
  /// Firebase AI Logic location, also used for server prompt templates.
  /// Newer models such as `gemini-3.8-flash` are not served in regional
  /// locations like `us-central1`, so the `global` location is used.
  static const String firebaseAILocation = 'global';

  /// How long an HTTP client waits to connect to a server.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// How long an HTTP client waits for data from a server.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Browser errors that are shown to the user instead of only logged.
  static const List<String> platformErrorMarkers = [
    'Illegal invocation',
    'document.createEvent',
  ];
}

final UncaughtErrorReporter _uncaughtErrorReporter = UncaughtErrorReporter();

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _startApp();
    },
    (error, stackTrace) async {
      // Last line of defence for errors nothing else handled. Reports to error
      // monitoring (guarded against recursion) and prints as a fallback.
      _uncaughtErrorReporter.report(error, stackTrace);
    },
  );
}

/// Initializes the app and runs it.
///
/// If initialization fails, [StartupErrorApp] is shown. Without it the HTML
/// loading indicator of the web page would stay on screen forever.
Future<void> _startApp() async {
  final MyApp app;
  try {
    app = await _initializeApp();
  } catch (error, stackTrace) {
    _uncaughtErrorReporter.report(error, stackTrace);
    runApp(const StartupErrorApp(onRetry: _retryStartup));
    return;
  }

  _installWebErrorHandler();
  runApp(SentryWidget(child: app));
}

Future<void> _retryStartup() async {
  if (kIsWeb) {
    // Reload the page: a clean page is more reliable than initializing again
    // next to whatever the failed attempt left behind. Without the fragment
    // the browser loads the page again instead of only scrolling to the
    // fragment.
    await launchUrl(Uri.base.removeFragment(), webOnlyWindowName: '_self');
    return;
  }
  await _startApp();
}

/// Initializes everything the app needs before the first frame.
Future<MyApp> _initializeApp() async {
  AppSecrets.validate();

  // A retry runs this again, and Firebase may have been initialized by then.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final firebaseRemoteConfigRepository = FirebaseRemoteConfigRepository(
    firebaseRemoteConfig: FirebaseRemoteConfig.instance,
  );
  // Does not throw: if the fetch fails (offline, timeout) the defaults are used.
  await firebaseRemoteConfigRepository.initialize();

  // Error monitoring starts first so that the steps below can report problems.
  // Its DSN comes from Remote Config.
  final errorMonitoringClients = await _getErrorMonitoringClients(
    firebaseRemoteConfigRepository,
  );
  final errorMonitoringFacade = ErrorMonitoringFacade(errorMonitoringClients);
  _uncaughtErrorReporter.errorMonitoring = errorMonitoringFacade;

  await _activateAppCheck(
    firebaseRemoteConfigRepository,
    errorMonitoringFacade,
  );

  final analyticsClients = await _getAnalyticsClients(
    firebaseRemoteConfigRepository,
    errorMonitoringFacade,
  );

  return MyApp(
    firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
    analyticsClients: analyticsClients,
    errorMonitoringClients: errorMonitoringClients,
  );
}

/// Activates Firebase App Check.
///
/// This must run before the first `FirebaseAI.agentPlatform()` call:
/// firebase_ai resolves App Check through
/// `app.getService<FirebaseAppCheck>()`, which is registered once
/// `FirebaseAppCheck.instance` is first accessed.
Future<void> _activateAppCheck(
  FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  ErrorMonitoringFacade errorMonitoringFacade,
) async {
  final recaptchaSiteKey = firebaseRemoteConfigRepository.recaptchaSiteKey;
  if (kIsWeb && recaptchaSiteKey.isEmpty) {
    // The reCAPTCHA provider fails in an opaque way without a site key. The
    // rest of the app works, so skip App Check: AI requests are then rejected
    // by the backend, which the travel form reports as an App Check error.
    errorMonitoringFacade.captureMessage(
      'Firebase App Check was not activated: the reCAPTCHA site key is empty.',
      level: 'error',
      context: {
        'remoteConfigKey': RemoteConfigs.recaptchaSiteKey.key,
      },
    );
    return;
  }

  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaV3Provider(recaptchaSiteKey),
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleDeviceCheckProvider(),
  );
}

/// Keeps showing known browser errors to the user, without replacing the
/// handler that reports Flutter errors to error monitoring.
void _installWebErrorHandler() {
  if (!kIsWeb) {
    return;
  }

  // Sentry (see `_getErrorMonitoringClients`) installed its own handler.
  // Overwriting it would stop Flutter errors from being reported.
  final previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exceptionAsString();
    if (_Constants.platformErrorMarkers.any(errorString.contains)) {
      _showPlatformErrorDialog();
    }
    (previous ?? FlutterError.presentError)(details);
  };
}

bool _isPlatformErrorDialogVisible = false;

void _showPlatformErrorDialog() {
  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted || _isPlatformErrorDialogVisible) {
    return;
  }

  _isPlatformErrorDialogVisible = true;
  showDialog<void>(
    context: context,
    builder: (context) => const TravelFormErrorDialog(
      error: PlatformOrBrowserError(),
    ),
  ).whenComplete(() => _isPlatformErrorDialogVisible = false);
}

Future<List<AnalyticsClient>> _getAnalyticsClients(
  FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  ErrorMonitoringFacade errorMonitoringFacade,
) async {
  if (kDebugMode) {
    return [
      LoggerAnalyticsClient(),
    ];
  }

  final firebaseAnalyticsClient = FirebaseAnalyticsClient(
    analytics: FirebaseAnalytics.instance,
  );
  final mixpanelProjectToken =
      firebaseRemoteConfigRepository.mixpanelProjectToken;
  if (mixpanelProjectToken.isEmpty) {
    return [firebaseAnalyticsClient];
  }

  try {
    final mixpanel = await Mixpanel.init(
      mixpanelProjectToken,
      trackAutomaticEvents: true,
    );
    return [
      MixpanelAnalyticsClient(
        mixpanel: mixpanel,
      ),
      firebaseAnalyticsClient,
    ];
  } catch (error, stackTrace) {
    // Analytics must not stop the app from starting.
    errorMonitoringFacade.reportError(
      'Mixpanel failed to initialize.',
      stackTrace: stackTrace,
      context: {'error': error},
    );
    return [firebaseAnalyticsClient];
  }
}

Future<List<ErrorMonitoringClient>> _getErrorMonitoringClients(
  FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
) async {
  if (kDebugMode) {
    return [
      LoggerErrorMonitoringClient(),
    ];
  }

  try {
    final sentryClient = SentryErrorMonitoringClient();
    await sentryClient.init(
      dsn: firebaseRemoteConfigRepository.sentryDsn,
      firebaseRemoteConfig: firebaseRemoteConfigRepository.firebaseRemoteConfig,
      debug: kDebugMode,
      environment: kDebugMode ? 'dev' : 'prod',
      considerInAppFramesByDefault: false,
      attachScreenshot: true,
      attachViewHierarchy: true,
    );
    return [
      sentryClient,
    ];
  } catch (error, stackTrace) {
    // Error monitoring must not stop the app from starting.
    debugPrint('Error monitoring failed to initialize: $error\n$stackTrace');
    return [
      LoggerErrorMonitoringClient(),
    ];
  }
}

/// Creates an HTTP client with timeouts, so that a stalled server cannot keep
/// a request (and the loading screen) waiting forever.
Dio _createDio() {
  return Dio(
    BaseOptions(
      connectTimeout: _Constants.connectTimeout,
      receiveTimeout: _Constants.receiveTimeout,
    ),
  )..addSentryInterceptor();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({
    required this.firebaseRemoteConfigRepository,
    required this.analyticsClients,
    required this.errorMonitoringClients,
    super.key,
  });

  final FirebaseRemoteConfigRepository firebaseRemoteConfigRepository;
  final List<AnalyticsClient> analyticsClients;
  final List<ErrorMonitoringClient> errorMonitoringClients;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider.value(
          value: firebaseRemoteConfigRepository,
        ),
        RepositoryProvider(
          create: (_) {
            // A failing analytics client is reported once per distinct
            // failure instead of once per event.
            final reportedFailures = <String>{};
            return AnalyticsFacade(
              analyticsClients,
              onError: (error, stackTrace, client) {
                if (!reportedFailures.add('${client.name}: $error')) {
                  return;
                }
                ErrorMonitoringFacade(errorMonitoringClients).reportError(
                  'Analytics client failed.',
                  stackTrace: stackTrace,
                  context: {
                    'error': error,
                    'analyticsClient': client.name,
                  },
                );
              },
            )..setAnalyticsCollectionEnabled(true);
          },
        ),
        RepositoryProvider(
          create: (_) => ErrorMonitoringFacade(
            errorMonitoringClients,
          ),
        ),
        RepositoryProvider(
          create: (context) {
            final dio = _createDio();
            final imageService = ImageToBase64Service(dio: dio);
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();

            return ImageRepository(
              imageService: imageService,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final dio = _createDio();
            final openMeteoService = OpenMeteoService(dio);
            final firebaseRemoteConfigRepository = context
                .read<FirebaseRemoteConfigRepository>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return WeatherRepository(
              openMeteoService,
              firebaseRemoteConfigRepository,
              errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final dio = _createDio();
            final freeCurrencyApiService = FreeCurrencyApiService(dio);
            final firebaseRemoteConfigRepository = context
                .read<FirebaseRemoteConfigRepository>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return CurrencyRepository(
              freeCurrencyApiService: freeCurrencyApiService,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final firebaseRemoteConfigRepository = context
                .read<FirebaseRemoteConfigRepository>();
            // App Check is attached automatically (activated in `main`).
            final agentPlatform = FirebaseAI.agentPlatform(
              app: Firebase.app(),
              location: _Constants.firebaseAILocation,
            );
            final firebaseAIService = FirebaseAIService(
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              firebaseAI: agentPlatform,
            );
            final currencyRepository = context.read<CurrencyRepository>();
            final weatherRepository = context.read<WeatherRepository>();
            final analyticsFacade = context.read<AnalyticsFacade>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            // Server prompt templates are preferred when enabled in Remote
            // Config; the client-built passes stay as the fallback.
            final templateClient = FirebaseTravelTemplateClient(
              firebaseAI: agentPlatform,
            );
            final travelResearchPass = TemplateAwareResearchPass(
              templatePass: TemplateTravelResearchPass(
                templateClient: templateClient,
                dispatcher: FunctionCallDispatcher(
                  currencyRepository: currencyRepository,
                  weatherRepository: weatherRepository,
                ),
                templateId: () =>
                    firebaseRemoteConfigRepository.aiResearchTemplateId,
                errorMonitoring: errorMonitoringFacade,
              ),
              fallbackPass: TravelResearchPass(
                firebaseAIService: firebaseAIService,
                currencyRepository: currencyRepository,
                weatherRepository: weatherRepository,
                errorMonitoring: errorMonitoringFacade,
              ),
              remoteConfig: firebaseRemoteConfigRepository,
              errorMonitoring: errorMonitoringFacade,
            );
            final travelFormatPass = TemplateAwareFormatPass(
              templatePass: TemplateTravelFormatPass(
                templateClient: templateClient,
                templateId: () =>
                    firebaseRemoteConfigRepository.aiFormatTemplateId,
                errorMonitoring: errorMonitoringFacade,
              ),
              fallbackPass: TravelFormatPass(
                firebaseAIService: firebaseAIService,
                errorMonitoring: errorMonitoringFacade,
              ),
              remoteConfig: firebaseRemoteConfigRepository,
              errorMonitoring: errorMonitoringFacade,
            );
            return FirebaseAIRepository(
              modelName: firebaseAIService.model,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              travelResearchPass: travelResearchPass,
              travelFormatPass: travelFormatPass,
              analyticsFacade: analyticsFacade,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final dio = _createDio();
            final apiService = AirportApiService(dio);
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return AirportRepository(
              apiService: apiService,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final dio = _createDio();
            final unsplashService = UnsplashService(dio);
            final firebaseRemoteConfigRepository = context
                .read<FirebaseRemoteConfigRepository>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return UnsplashRepository(
              unsplashService: unsplashService,
              dio: dio,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            final dio = _createDio();
            final countryService = CountryService(dio: dio);
            final firebaseAIRepository = context.read<FirebaseAIRepository>();
            final airportRepository = context.read<AirportRepository>();
            final unsplashRepository = context.read<UnsplashRepository>();
            final currencyRepository = context.read<CurrencyRepository>();
            final firebaseRemoteConfigRepository = context
                .read<FirebaseRemoteConfigRepository>();
            final imageRepository = context.read<ImageRepository>();
            final analyticsFacade = context.read<AnalyticsFacade>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            final travelPurposeService = TravelPurposeService(
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
            );
            return TravelFormBloc(
              analyticsFacade: analyticsFacade,
              errorMonitoringFacade: errorMonitoringFacade,
              countryService: countryService,
              firebaseAIRepository: firebaseAIRepository,
              airportRepository: airportRepository,
              unsplashRepository: unsplashRepository,
              currencyRepository: currencyRepository,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              imageRepository: imageRepository,
              travelPurposeService: travelPurposeService,
            )..add(TravelFormStarted());
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        home: const TravelFormScreen(),
        routes: {'/results': (context) => const ResultsScreen()},
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
      ),
    );
  }
}
