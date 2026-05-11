import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'required_documents.g.dart';

enum RequiredDocumentType {
  @JsonValue('passport')
  passport,
  @JsonValue('e_visa')
  eVisa,
  @JsonValue('visa')
  visa,
  @JsonValue('id_card')
  idCard,
  @JsonValue('other')
  other,
}

@JsonSerializable(createToJson: false)
class RequiredDocuments {
  const RequiredDocuments({
    required this.documentType,
    required this.message,
    this.steps,
    this.moreInformation,
  });

  factory RequiredDocuments.fromJson(Map<String, dynamic> json) =>
      _$RequiredDocumentsFromJson(json);

  @JsonKey(name: 'type')
  final RequiredDocumentType documentType;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'steps')
  final List<String>? steps;

  @JsonKey(name: 'more_information')
  final String? moreInformation;

  static List<String> get documentTypeSchemaValues => RequiredDocumentType
      .values
      .map((type) => _$RequiredDocumentTypeEnumMap[type]!)
      .toList(growable: false);

  static Schema get aiSchema => Schema.object(
    properties: {
      'type': Schema.enumString(
        enumValues: documentTypeSchemaValues,
        description:
            'Allowed values only: ${documentTypeSchemaValues.join(', ')}',
      ),
      'message': Schema.string(),
      'steps': Schema.array(items: Schema.string(), nullable: true),
      'more_information': Schema.string(nullable: true),
    },
    optionalProperties: ['steps', 'more_information'],
  );
}
