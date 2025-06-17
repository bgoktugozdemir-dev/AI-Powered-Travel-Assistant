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
import 'package:sentry_dio/sentry_dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:travel_assistant/common/repositories/airport_repository.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_ai_repository.dart';
import 'package:travel_assistant/common/repositories/image_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/services/country_service.dart';
import 'package:travel_assistant/common/services/free_currency_api_service.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/services/image_to_base64_service.dart';
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
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/travel_form_screen.dart';
import 'package:travel_assistant/firebase_options.dart';
import 'package:travel_assistant/common/theme/app_theme.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:travel_assistant/features/travel_form/error/travel_form_error.dart';
import 'package:travel_assistant/features/travel_form/ui/dialog/travel_form_error_dialog.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final firebaseRemoteConfigRepository = FirebaseRemoteConfigRepository(
        firebaseRemoteConfig: FirebaseRemoteConfig.instance,
      );
      await firebaseRemoteConfigRepository.initialize();

      // Activate Firebase App Check
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(
          firebaseRemoteConfigRepository.recaptchaSiteKey,
        ),
        androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
      );

      final analyticsClients = await _getAnalyticsClients(
        firebaseRemoteConfigRepository,
      );
      final errorMonitoringClients = await _getErrorMonitoringClients(
        firebaseRemoteConfigRepository,
      );

      runApp(
        SentryWidget(
          child: MyApp(
            firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
            analyticsClients: analyticsClients,
            errorMonitoringClients: errorMonitoringClients,
          ),
        ),
      );

      // Global error handler for web platform/browser errors
      if (kIsWeb) {
        FlutterError.onError = (FlutterErrorDetails details) {
          final errorString = details.exceptionAsString();
          if (errorString.contains('Illegal invocation') || errorString.contains('document.createEvent')) {
            showDialog(
              context: navigatorKey.currentContext!,
              builder:
                  (context) => const TravelFormErrorDialog(
                    error: PlatformOrBrowserError(),
                  ),
            );
          } else {
            FlutterError.dumpErrorToConsole(details);
          }
        };
      }
    },
    (error, stackTrace) async {
      // Error monitoring is handled by the facade in the app
      // This is just a fallback for catastrophic failures
      debugPrint('Global error handler: $error');
    },
  );
}

Future<List<AnalyticsClient>> _getAnalyticsClients(
  FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
) async {
  if (kDebugMode) {
    return [
      LoggerAnalyticsClient(),
    ];
  }

  final mixpanelProjectToken = firebaseRemoteConfigRepository.mixpanelProjectToken;
  if (mixpanelProjectToken.isEmpty) {
    return [
      FirebaseAnalyticsClient(
        analytics: FirebaseAnalytics.instance,
      ),
    ];
  }

  final mixpanel = await Mixpanel.init(
    mixpanelProjectToken,
    trackAutomaticEvents: true,
  );

  return [
    MixpanelAnalyticsClient(
      mixpanel: mixpanel,
    ),
    FirebaseAnalyticsClient(
      analytics: FirebaseAnalytics.instance,
    ),
  ];
}

Future<List<ErrorMonitoringClient>> _getErrorMonitoringClients(
  FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
) async {
  late final List<ErrorMonitoringClient> clients;

  if (kDebugMode) {
    clients = [
      LoggerErrorMonitoringClient(),
    ];
  } else {
    final sentryClient = SentryErrorMonitoringClient();
    await sentryClient.init(
      dsn: firebaseRemoteConfigRepository.sentryDsn,
      debug: kDebugMode,
      environment: kDebugMode ? 'dev' : 'prod',
      considerInAppFramesByDefault: false,
      attachScreenshot: true,
      attachViewHierarchy: true,
    );
    clients = [
      sentryClient,
    ];
  }

  return clients;
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
          create: (_) => AnalyticsFacade(analyticsClients)..setAnalyticsCollectionEnabled(true),
        ),
        RepositoryProvider(
          create:
              (_) => ErrorMonitoringFacade(
                errorMonitoringClients,
              ),
        ),
        RepositoryProvider(
          create: (context) {
            final dio = Dio()..addSentry();
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
            final vertexAI = FirebaseAI.vertexAI(
              appCheck: FirebaseAppCheck.instance,
              app: Firebase.app(),
            );
            final firebaseAIService = FirebaseAIService(
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              firebaseAI: vertexAI,
            );
            final analyticsFacade = context.read<AnalyticsFacade>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return FirebaseAIRepository(
              firebaseAIService: firebaseAIService,
              analyticsFacade: analyticsFacade,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final dio = Dio()..addSentry();
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
            final dio = Dio()..addSentry();
            final unsplashService = UnsplashService(dio);
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return UnsplashRepository(
              unsplashService: unsplashService,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final dio = Dio()..addSentry();
            final freeCurrencyApiService = FreeCurrencyApiService(dio);
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
            final errorMonitoringFacade = context.read<ErrorMonitoringFacade>();
            return CurrencyRepository(
              freeCurrencyApiService: freeCurrencyApiService,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              errorMonitoringFacade: errorMonitoringFacade,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            final dio = Dio()..addSentry();
            final countryService = CountryService(dio: dio);
            final firebaseAIRepository = context.read<FirebaseAIRepository>();
            final airportRepository = context.read<AirportRepository>();
            final unsplashRepository = context.read<UnsplashRepository>();
            final currencyRepository = context.read<CurrencyRepository>();
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
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
      ),
    );
  }
}
