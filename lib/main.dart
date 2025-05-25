import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_assistant/common/repositories/airport_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/gemini_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/services/api_logger_interceptor.dart';
import 'package:travel_assistant/common/services/gemini_service.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/travel_form_screen.dart';
import 'package:travel_assistant/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseRemoteConfigRepository = FirebaseRemoteConfigRepository(
    firebaseRemoteConfig: FirebaseRemoteConfig.instance,
  );
  await firebaseRemoteConfigRepository.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider.value(value: firebaseRemoteConfigRepository),
        RepositoryProvider(
          create: (_) {
            final geminiService = GeminiService(vertexAI: FirebaseVertexAI.instance);
            return GeminiRepository(geminiService: geminiService);
          },
        ),
        RepositoryProvider(
          create: (_) {
            final apiService = AirportApiService(Dio()..interceptors.add(ApiLoggerInterceptor()));
            return AirportRepository(apiService: apiService);
          },
        ),
        RepositoryProvider(
          create: (context) {
            final unsplashService = UnsplashService(Dio()..interceptors.add(ApiLoggerInterceptor()));
            final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();
            return UnsplashRepository(
              unsplashService: unsplashService,
              firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            final geminiRepository = context.read<GeminiRepository>();
            final airportRepository = context.read<AirportRepository>();
            return TravelFormBloc(geminiRepository: geminiRepository, airportRepository: airportRepository)
              ..add(TravelFormStarted());
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const TravelFormScreen(),
      routes: {'/results': (context) => const ResultsScreen()},
    );
  }
}
