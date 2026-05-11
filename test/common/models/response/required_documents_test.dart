import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/models/response/required_documents.dart';

void main() {
  group('RequiredDocuments', () {
    test('schema constrains type to expected enum values', () {
      final schemaJson = RequiredDocuments.aiSchema.toJson();
      final typeSchema =
          (schemaJson['properties'] as Map<String, dynamic>)['type']
              as Map<String, dynamic>;

      expect(typeSchema['type'], 'STRING');
      expect(
        typeSchema['enum'],
        ['passport', 'e_visa', 'visa', 'id_card', 'other'],
      );
    });

    test('parses supported lowercase enum values', () {
      final model = RequiredDocuments.fromJson({
        'type': 'visa',
        'message': 'Visa required',
        'steps': null,
        'more_information': null,
      });

      expect(model.documentType, RequiredDocumentType.visa);
    });

    test('rejects unsupported enum casing', () {
      expect(
        () => RequiredDocuments.fromJson({
          'type': 'Visa',
          'message': 'Visa required',
          'steps': null,
          'more_information': null,
        }),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
