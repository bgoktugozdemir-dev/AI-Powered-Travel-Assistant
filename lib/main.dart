import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:travel_assistant/common/repositories/airport_repository.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/gemini_repository.dart';
import 'package:travel_assistant/common/repositories/image_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/services/api_logger_interceptor.dart';
import 'package:travel_assistant/common/services/free_currency_api_service.dart';
import 'package:travel_assistant/common/services/gemini_service.dart';
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
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/travel_form_screen.dart';
import 'package:travel_assistant/firebase_options.dart';
import 'package:travel_assistant/common/theme/app_theme.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:travel_assistant/features/travel_form/error/travel_form_error.dart';
import 'package:travel_assistant/features/travel_form/ui/dialog/travel_form_error_dialog.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

      final analyticsClients = await _getAnalyticsClients(firebaseRemoteConfigRepository);
      final errorMonitoringClients = await _getErrorMonitoringClients(firebaseRemoteConfigRepository);

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
              builder: (context) => const TravelFormErrorDialog(error: PlatformOrBrowserError()),
            );
          } else {
            FlutterError.dumpErrorToConsole(details);
          }
        };
      }
    },
    (error, stackTrace) async {
      try {
        appLogger.e('Failed to capture error: $error', stackTrace: stackTrace);
      } catch (e) {
        appLogger.e('Failed to capture error: $e', stackTrace: stackTrace);
      }
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
          create: (_) => ErrorMonitoringFacade(errorMonitoringClients),
        ),
        RepositoryProvider(
          create: (_) {
            final dio = Dio();
            final imageService = ImageToBase64Service(dio: dio);
            return ImageRepository(imageService: imageService);
          },
        ),
        RepositoryProvider(
          create: (_) {
            final vertexAI = FirebaseAI.vertexAI(
              appCheck: FirebaseAppCheck.instance,
              app: Firebase.app(),
            );
            final geminiService = GeminiService(
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
              firebaseAI: vertexAI,
            );
            return GeminiRepository(geminiService: geminiService);
          },
        ),
        RepositoryProvider(
          create: (_) {
            final apiService = AirportApiService(
              Dio()..interceptors.add(ApiLoggerInterceptor()),
            );
            return AirportRepository(apiService: apiService);
          },
        ),
        RepositoryProvider(
          create: (context) {
            final unsplashService = UnsplashService(
              Dio()..interceptors.add(ApiLoggerInterceptor()),
            );
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
            return UnsplashRepository(
              unsplashService: unsplashService,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
            );
          },
        ),
        RepositoryProvider(
          create: (context) {
            final freeCurrencyApiService = FreeCurrencyApiService(
              Dio()..interceptors.add(ApiLoggerInterceptor()),
            );
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
            return CurrencyRepository(
              freeCurrencyApiService: freeCurrencyApiService,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            final geminiRepository = context.read<GeminiRepository>();
            final airportRepository = context.read<AirportRepository>();
            final unsplashRepository = context.read<UnsplashRepository>();
            final currencyRepository = context.read<CurrencyRepository>();
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
            final imageRepository = context.read<ImageRepository>();
            final travelPurposeService = TravelPurposeService(
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
            );
            return TravelFormBloc(
              geminiRepository: geminiRepository,
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
