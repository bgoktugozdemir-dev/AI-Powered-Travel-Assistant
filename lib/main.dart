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
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/travel_form_screen.dart';
import 'package:travel_assistant/firebase_options.dart';
import 'package:travel_assistant/common/theme/app_theme.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

Future<void> main() async {
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

  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: firebaseRemoteConfigRepository),
        RepositoryProvider(
          create: (context) {
            return AnalyticsFacade(analyticsClients);
          },
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
            final travelPurposeService = TravelPurposeService();
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
      child: MyApp(),
    ),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: const TravelFormScreen(),
      routes: {'/results': (context) => const ResultsScreen()},
    );
  }
}
