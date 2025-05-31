// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_currency_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FreeCurrencyApiResponse _$FreeCurrencyApiResponseFromJson(
  Map<String, dynamic> json,
) => _FreeCurrencyApiResponse(
  data: (json['data'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$FreeCurrencyApiResponseToJson(
  _FreeCurrencyApiResponse instance,
) => <String, dynamic>{'data': instance.data};
