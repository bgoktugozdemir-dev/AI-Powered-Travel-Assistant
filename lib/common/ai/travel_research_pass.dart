import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/ai/function_call_dispatcher.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const int maxToolCallRounds = 6;
}

/// Pass 1 orchestrator: tool-enabled research + grounding.
class TravelResearchPass {
  TravelResearchPass({
    required FirebaseAIService firebaseAIService,
    required CurrencyRepository currencyRepository,
    required WeatherRepository weatherRepository,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _firebaseAIService = firebaseAIService,
       _dispatcher = FunctionCallDispatcher(
         currencyRepository: currencyRepository,
         weatherRepository: weatherRepository,
       ),
       _errorMonitoring = errorMonitoring;

  final FirebaseAIService _firebaseAIService;
  final FunctionCallDispatcher _dispatcher;
  final ErrorMonitoringFacade _errorMonitoring;

  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    try {
      final model = _firebaseAIService.buildResearchModel(
        systemPrompt: systemPrompt,
      );

      final chat = model.startChat();
      var roundCount = 0;
      var currentPrompt = userPrompt;

      while (roundCount < _Constants.maxToolCallRounds) {
        roundCount++;
        final response = await chat.sendMessage(
          Content.text(currentPrompt),
        );
        final functionCalls = response.functionCalls.toList();
        if (functionCalls.isEmpty) {
          return response.text ?? '';
        }

        final functionResponses = <Part>[];
        for (final call in functionCalls) {
          functionResponses.add(await _dispatcher.dispatch(call));
        }

        await chat.sendMessage(Content.multi(functionResponses));
        currentPrompt = 'Continue with grounded research synthesis.';
      }

      _errorMonitoring.reportError(
        'TravelResearchPass max tool call rounds exceeded',
      );
      return 'Research pass exceeded maximum tool-call rounds.';
    } catch (e, st) {
      _errorMonitoring.reportError(
        'TravelResearchPass.generateResearchFindings failed: $e',
        stackTrace: st,
      );
      return 'Research pass failed.';
    }
  }
}
