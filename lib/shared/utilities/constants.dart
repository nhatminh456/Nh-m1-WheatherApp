// ignore_for_file: constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';
// chứa hằng số của app 
// đọc API key, lưu Url
class Constants {
  static String get WEATHER_APP_ID => dotenv.env['OPENWEATHER_API_KEY']!;
  static const String WEATHER_BASE_SCHEME = 'https://';
  static const String WEATHER_BASE_URL_DOMAIN = 'api.openweathermap.org';
  static const String WEATHER_FORECAST_PATH = 'data/2.5/forecast';
  static const String WEATHER_IMAGES_PATH = '/img/w/';
  static const String WEATHER_IMAGES_URL =
      WEATHER_BASE_SCHEME + WEATHER_BASE_URL_DOMAIN + WEATHER_IMAGES_PATH;
}
