// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxInformation _$TaxInformationFromJson(Map<String, dynamic> json) =>
    TaxInformation(
      hasTaxFreeOptions: json['has_tax_free_options'] as bool,
      taxRate: (json['tax_rate'] as num).toDouble(),
      refundableTaxRate: (json['refundable_tax_rate'] as num?)?.toDouble() ?? 0,
      taxRefundInformation: json['tax_refund_information'] as String,
    );
