import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

/// The server's streamed response could not be read, e.g. a 5xx whose body
/// is not JSON. Thrown instead of the underlying [FormatException] so it is
/// not mistaken for model output that failed to parse (which is retried).
class UnreadableResponseException implements Exception {
  const UnreadableResponseException(this.cause);

  final FormatException cause;

  @override
  String toString() => 'UnreadableResponseException($cause)';
}

/// How one streamed request went, for diagnosing requests a browser cut off.
class StreamedResponseTiming {
  const StreamedResponseTiming({
    required this.totalMs,
    required this.firstChunkMs,
    required this.longestSilenceMs,
    required this.chunkCount,
    required this.failed,
  });

  /// Time from sending the request until the stream ended or failed.
  final int totalMs;

  /// Time until the first chunk arrived, or null when none arrived.
  final int? firstChunkMs;

  /// Longest stretch without a chunk, counting from the request and up to
  /// the end of the stream. Safari cuts a request off after about 60 seconds
  /// of silence.
  final int longestSilenceMs;

  final int chunkCount;

  /// Whether the stream ended with an error.
  final bool failed;

  Map<String, Object?> toJson() => {
    'totalMs': totalMs,
    'firstChunkMs': firstChunkMs,
    'longestSilenceMs': longestSilenceMs,
    'chunkCount': chunkCount,
    'failed': failed,
  };
}

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
///
/// [onDone] receives the request's timing once the stream ends, also when it
/// fails. A [FormatException] from the stream is rethrown as an
/// [UnreadableResponseException].
Future<GenerateContentResponse> collectStreamedResponse(
  Stream<GenerateContentResponse> chunks, {
  void Function(StreamedResponseTiming timing)? onDone,
}) async {
  final stopwatch = Stopwatch()..start();
  int? firstChunkMs;
  var lastChunkMs = 0;
  var longestSilenceMs = 0;
  var chunkCount = 0;
  var failed = false;

  final parts = <Part>[];
  String? role;
  Candidate? lastCandidate;
  PromptFeedback? promptFeedback;
  UsageMetadata? usageMetadata;

  try {
    await for (final chunk in chunks) {
      final nowMs = stopwatch.elapsedMilliseconds;
      firstChunkMs ??= nowMs;
      if (nowMs - lastChunkMs > longestSilenceMs) {
        longestSilenceMs = nowMs - lastChunkMs;
      }
      lastChunkMs = nowMs;
      chunkCount++;

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
  } on FormatException catch (e, st) {
    failed = true;
    Error.throwWithStackTrace(UnreadableResponseException(e), st);
  } catch (_) {
    failed = true;
    rethrow;
  } finally {
    final totalMs = stopwatch.elapsedMilliseconds;
    if (totalMs - lastChunkMs > longestSilenceMs) {
      longestSilenceMs = totalMs - lastChunkMs;
    }
    onDone?.call(
      StreamedResponseTiming(
        totalMs: totalMs,
        firstChunkMs: firstChunkMs,
        longestSilenceMs: longestSilenceMs,
        chunkCount: chunkCount,
        failed: failed,
      ),
    );
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

/// An `onDone` for [collectStreamedResponse] that leaves the timing of the
/// [request] as a breadcrumb, so it is attached to a failure reported later.
void Function(StreamedResponseTiming timing) timingBreadcrumb(
  ErrorMonitoringFacade errorMonitoring,
  String request,
) =>
    (timing) => errorMonitoring.addBreadcrumb(
      'Firebase AI request finished.',
      category: 'Firebase AI',
      data: {'request': request, ...timing.toJson()},
    );
