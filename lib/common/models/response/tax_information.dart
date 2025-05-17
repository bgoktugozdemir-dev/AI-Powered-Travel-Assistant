import 'package:json_annotation/json_annotation.dart';

part 'tax_information.g.dart';

@JsonSerializable(createToJson: false)
class TaxInformation {
  const TaxInformation({required this.hasTaxFreeOptions, required this.taxRate, required this.taxRefundInformation});

  factory TaxInformation.fromJson(Map<String, dynamic> json) => _$TaxInformationFromJson(json);

  @JsonKey(name: 'has_tax_free_options')
  final bool hasTaxFreeOptions;

  @JsonKey(name: 'tax_rate')
  final double taxRate;

  @JsonKey(name: 'tax_refund_information')
  final String taxRefundInformation;
}
