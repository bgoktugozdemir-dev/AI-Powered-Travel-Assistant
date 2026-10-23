import 'package:firebase_ai/firebase_ai.dart';

/// Reads a streamed generation to the end and merges its chunks into the
/// response a non-streaming call would have returned.
///
/// The passes stream instead of waiting for one response because Safari
/// (WebKit) fails a request with "Load failed" when no response bytes arrive
/// for 60 seconds, which a long non-streaming generation easily exceeds.
/// Streamed chunks keep the connection alive.
///
/// The parts of every chunk's first candidate are concatenated in order, so
/// [GenerateContentResponse.text] and [GenerateContentResponse.functionCalls]
/// read the same as on a single response. The finish reason, safety ratings
/// and usage come from the last chunk that carries them.
Future<GenerateContentResponse> collectStreamedResponse(
  Stream<GenerateContentResponse> chunks,
) async {
  final parts = <Part>[];
  String? role;
  Candidate? lastCandidate;
  PromptFeedback? promptFeedback;
  UsageMetadata? usageMetadata;

  await for (final chunk in chunks) {
    promptFeedback = chunk.promptFeedback ?? promptFeedback;
    usageMetadata = chunk.usageMetadata ?? usageMetadata;
    final candidate = chunk.candidates.firstOrNull;
    if (candidate == null) {
      continue;
    }
    role ??= candidate.content.role;
    parts.addAll(candidate.content.parts);
    lastCandidate = candidate;
  }

  if (lastCandidate == null) {
    return GenerateContentResponse(
      const [],
      promptFeedback,
      usageMetadata: usageMetadata,
    );
  }
  return GenerateContentResponse(
    [
      Candidate(
        Content(role, parts),
        lastCandidate.safetyRatings,
        lastCandidate.citationMetadata,
        lastCandidate.finishReason,
        lastCandidate.finishMessage,
        groundingMetadata: lastCandidate.groundingMetadata,
        urlContextMetadata: lastCandidate.urlContextMetadata,
      ),
    ],
    promptFeedback,
    usageMetadata: usageMetadata,
  );
}
