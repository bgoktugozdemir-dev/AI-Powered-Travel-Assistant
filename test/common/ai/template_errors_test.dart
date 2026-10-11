import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/template_errors.dart';
import 'package:travel_assistant/common/ai/travel_research_pass.dart';

void main() {
  group('isTemplateUnavailableError', () {
    test('is true for a not found server error', () {
      expect(
        isTemplateUnavailableError(
          ServerException('Requested entity was not found.'),
        ),
        isTrue,
      );
      expect(
        isTemplateUnavailableError(
          ServerException('Template travel-research NOT_FOUND'),
        ),
        isTrue,
      );
    });

    test('is true for an invalid template server error', () {
      expect(
        isTemplateUnavailableError(
          ServerException('The prompt template is invalid: bad frontmatter'),
        ),
        isTrue,
      );
    });

    test('unwraps errors wrapped by the research pass', () {
      expect(
        isTemplateUnavailableError(
          TravelResearchPassException(
            'Research pass failed.',
            cause: ServerException('template not found'),
          ),
        ),
        isTrue,
      );
    });

    test('is false for App Check and other server errors', () {
      expect(
        isTemplateUnavailableError(
          ServerException('Firebase App Check token is invalid.'),
        ),
        isFalse,
      );
      expect(
        isTemplateUnavailableError(ServerException('Quota exceeded')),
        isFalse,
      );
      expect(
        isTemplateUnavailableError(
          TravelResearchPassException(
            'Research pass failed.',
            cause: ServerException('app check rejected'),
          ),
        ),
        isFalse,
      );
    });

    test('is false for errors that are not server errors', () {
      expect(isTemplateUnavailableError(Exception('not found')), isFalse);
      expect(
        isTemplateUnavailableError(const FormatException('not found')),
        isFalse,
      );
      expect(
        isTemplateUnavailableError(
          const TravelResearchPassException('exceeded rounds'),
        ),
        isFalse,
      );
    });
  });
}
