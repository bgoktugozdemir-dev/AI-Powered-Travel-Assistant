import 'package:json_annotation/json_annotation.dart';

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
  const RequiredDocuments({required this.documentType, required this.message, this.steps, this.moreInformation});

  factory RequiredDocuments.fromJson(Map<String, dynamic> json) => _$RequiredDocumentsFromJson(json);

  @JsonKey(name: 'type')
  final RequiredDocumentType documentType;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'steps')
  final List<String>? steps;

  @JsonKey(name: 'more_information')
  final String? moreInformation;
}
