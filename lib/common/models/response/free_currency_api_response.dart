import 'package:freezed_annotation/freezed_annotation.dart';

part 'free_currency_api_response.freezed.dart';
part 'free_currency_api_response.g.dart';

@freezed
abstract class FreeCurrencyApiResponse with _$FreeCurrencyApiResponse {
  const FreeCurrencyApiResponse._();

  const factory FreeCurrencyApiResponse({
    required Map<String, double> data,
  }) = _FreeCurrencyApiResponse;

  factory FreeCurrencyApiResponse.fromJson(Map<String, dynamic> json) => _$FreeCurrencyApiResponseFromJson(json);
}
