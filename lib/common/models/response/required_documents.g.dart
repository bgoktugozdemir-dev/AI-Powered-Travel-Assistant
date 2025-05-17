// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'required_documents.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequiredDocuments _$RequiredDocumentsFromJson(Map<String, dynamic> json) =>
    RequiredDocuments(
      documentType: $enumDecode(_$RequiredDocumentTypeEnumMap, json['type']),
      message: json['message'] as String,
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList(),
      moreInformation: json['more_information'] as String?,
    );

const _$RequiredDocumentTypeEnumMap = {
  RequiredDocumentType.passport: 'passport',
  RequiredDocumentType.eVisa: 'e_visa',
  RequiredDocumentType.visa: 'visa',
  RequiredDocumentType.idCard: 'id_card',
  RequiredDocumentType.other: 'other',
};
