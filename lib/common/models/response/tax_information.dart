import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'tax_information.g.dart';

@JsonSerializable(createToJson: false)
class TaxInformation {
  const TaxInformation({
    required this.hasTaxFreeOptions,
    required this.taxRate,
    required this.refundableTaxRate,
    required this.taxRefundInformation,
  });

  factory TaxInformation.fromJson(Map<String, dynamic> json) =>
      _$TaxInformationFromJson(json);

  @JsonKey(name: 'has_tax_free_options')
  final bool hasTaxFreeOptions;

  @JsonKey(name: 'tax_rate')
  final double taxRate;

  @JsonKey(name: 'refundable_tax_rate', defaultValue: 0)
  final double refundableTaxRate;

  @JsonKey(name: 'tax_refund_information')
  final String? taxRefundInformation;

  static Schema get aiSchema => Schema.object(
    properties: {
      'has_tax_free_options': Schema.boolean(),
      'tax_rate': Schema.number(),
      'refundable_tax_rate': Schema.number(),
      'tax_refund_information': Schema.string(nullable: true),
    },
    optionalProperties: ['tax_refund_information'],
  );
}
