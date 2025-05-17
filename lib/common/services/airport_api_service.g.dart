// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirportFields _$AirportFieldsFromJson(Map<String, dynamic> json) =>
    AirportFields(
      iataCode: json['column_1'] as String,
      name: json['airport_name'] as String,
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      cityName: json['city_name'] as String,
    );

Map<String, dynamic> _$AirportFieldsToJson(AirportFields instance) =>
    <String, dynamic>{
      'column_1': instance.iataCode,
      'airport_name': instance.name,
      'country_code': instance.countryCode,
      'country_name': instance.countryName,
      'city_name': instance.cityName,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _AirportApiService implements AirportApiService {
  _AirportApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://data.opendatasoft.com/api/records/1.0/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<AirportApiResponse> searchAirports(
    String datasetId,
    String query, {
    int rows = 10,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'dataset': datasetId,
      r'q': query,
      r'rows': rows,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<AirportApiResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/search/',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AirportApiResponse _value;
    try {
      _value = AirportApiResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
