import 'feels_like.dart';
import 'temp.dart';
import 'weather.dart';
import '../utilities/constants.dart';
// Là model dùng lưu thông tin dự báo weather

class WheatherList {
  int? dt; // thời gian dự báo
  int? sunrise; // mặt trời mọc
  int? sunset; // mặt trời lặn
  Temp? temp; // nhiệt độ
  FeelsLike? feelsLike; // cảm nhận
  int? pressure; // áp suất
  int? humidity; // độ ẩm
  List<Weather>? weather; // thông tin thời tiết
  double? speed; // tốc độ gió
  int? deg; // hướng gió
  num? gust; // gió giật
  int? clouds; // mây
  double? pop; // tỉ lệ mưa
  num? rain; // mưa

  WheatherList({
    this.dt,
    this.sunrise,
    this.sunset,
    this.temp,
    this.feelsLike,
    this.pressure,
    this.humidity,
    this.weather,
    this.speed,
    this.deg,
    this.gust,
    this.clouds,
    this.pop,
    this.rain,
  });

  WheatherList.fromJson(Map<String, dynamic> json) {
    dt = json['dt'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    temp = json['temp'] != null ? Temp.fromJson(json['temp']) : null;
    feelsLike = json['feels_like'] != null
        ? FeelsLike.fromJson(json['feels_like'])
        : null;
    pressure = json['pressure'];
    humidity = json['humidity'];
    if (json['weather'] != null) {
      weather = <Weather>[];
      json['weather'].forEach((v) {
        weather!.add(Weather.fromJson(v));
      });
    }
    speed = json['speed'];
    deg = json['deg'];
    gust = json['gust'];
    clouds = json['clouds'];
    pop = json['pop'].toDouble();
    rain = json['rain'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dt'] = dt;
    data['sunrise'] = sunrise;
    data['sunset'] = sunset;
    if (temp != null) {
      data['temp'] = temp!.toJson();
    }
    if (feelsLike != null) {
      data['feels_like'] = feelsLike!.toJson();
    }
    data['pressure'] = pressure;
    data['humidity'] = humidity;
    if (weather != null) {
      data['weather'] = weather!.map((v) => v.toJson()).toList();
    }
    data['speed'] = speed;
    data['deg'] = deg;
    data['gust'] = gust;
    data['clouds'] = clouds;
    data['pop'] = pop;
    data['rain'] = rain;
    return data;
  }
// Nếu không có hai phương thức này thì phải tự ánh xạ từng trường dữ liệu
// ở nhiều nơi trong chương trình, khiến code dài, 
//lặp lại và khó bảo trì.
  String getIconUrl() {
    return '${Constants.WEATHER_IMAGES_URL}${weather![0].icon!}.png';
  }
}
