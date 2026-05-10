import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_assistant/common/models/response/open_meteo_response.dart';

part 'open_meteo_service.g.dart';

@RestApi(baseUrl: 'https://api.open-meteo.com/v1')
abstract class OpenMeteoService {
  factory OpenMeteoService(Dio dio, {String baseUrl}) = _OpenMeteoService;

  @GET('/forecast')
  Future<OpenMeteoResponse> getWeatherForecast({
    @Query('latitude') required double latitude,
    @Query('longitude') required double longitude,
    @Query('start_date') required String startDate,
    @Query('end_date') required String endDate,
    @Query('hourly') required String hourly,
    @Query('current') required String current,
    @Query('timezone') String timezone = 'auto',
  });
}
